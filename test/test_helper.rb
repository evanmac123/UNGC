require 'simplecov'
require 'factory_girl'
SimpleCov.start
require 'fake_stripe'

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'
require "capybara/poltergeist"
require 'mocha/setup'
require 'webmock/minitest'
require 'test_helpers/integration_test_helper'
require "#{Rails.root}/db/seeds.rb"

# include helpers, modules etc
require_relative "support/test_page/base.rb"
Dir[Rails.root.join("test/support/**/*.rb")].each { |f| require f }

Minitest::Reporters.use! [
                             Minitest::Reporters::ProgressReporter.new,
                         ] unless ENV["RM_INFO"] || ENV["TEAMCITY_VERSION"]

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  # Add more helper methods to be used by all tests here...
  include ActionDispatch::TestProcess

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  def as(user)
    user.try(:id) ? {user_id: user.id} : {}
  end

  def assert_redirected_to_index
    assert_redirected_to action: 'index'
  end

  def assert_layout(layout)
    assert_equal "layouts/#{layout}", @response.layout
  end

  def create_new_logo_request
    create_organization_and_user
    create_ungc_organization_and_user
    create(:logo_publication)
    @logo_request = create(:logo_request, contact_id: @organization_user.id,
                                          organization_id: @organization.id)
  end

  def create_approved_logo_request
    create_new_logo_request
    # we need a comment before approving
    @logo_request.logo_files << create(:logo_file, zip: fixture_file_upload('files/untitled.pdf', 'application/pdf'))
    @logo_request.logo_comments.create(body: 'lorem ipsum',
                                       contact_id: @staff_user.id,
                                       attachment: fixture_file_upload('files/untitled.pdf', 'application/pdf'),
                                       state_event: LogoRequest::EVENT_REVISE)
    @logo_request.approve
  end

  def create_non_business_organization_and_user(state=nil)
    @organization = create(:organization, :with_contact, employees: 50,
                                        organization_type: OrganizationType.academic)
    @organization.approve! if state == 'approved'
    @organization_user = @organization.contacts.contact_points.first
  end

  def create_organization_and_user(state=nil)
    sector = create(:sector)
    listing_status = create(:listing_status)
    @organization = create(:organization, :with_contact, employees: 50,
                                        organization_type: OrganizationType.sme,
                                        sector: sector,
                                        listing_status: listing_status,
                                        cop_due_on: Date.current + 1.year)
    @organization.approve! if state == 'approved'
    @organization_user = @organization.contacts.contact_points.first
  end

  def create_organization_and_ceo
    create_organization_and_user
    @organization_ceo = create(:ceo_contact, organization_id: @organization.id)
  end

  def create_approved_organization_and_user
      create_organization_and_user
      @organization.approve!.tap do
        @organization_user.reload
      end
  end

  def create_cop_with_options(cop_options = {})
    defaults = {
      :title                               => "COP Title",
      :references_human_rights             => true,
      :references_labour                   => true,
      :references_environment              => true,
      :references_anti_corruption          => true,
      :include_measurement                 => true,
      :include_continued_support_statement => true
    }

    create_principle_areas
    @cop = create_cop(@organization.id, defaults.merge(cop_options))
  end

  def create_financial_contact
    @financial_contact = create(:contact, :financial_contact, organization_id: @organization.id)
  end

  def create_ungc_organization_and_user
    # Legacy, the UNGC organization is now created in the seeds
    # all we have left to do is create the staff user
    create_staff_user
  end

  def create_staff_user
    @ungc = Organization.find_by!(name: DEFAULTS[:ungc_organization_name])
    @staff_user = create(:contact, username: 'staff',
                                 password: 'Passw0rd',
                                 organization_id: @ungc.id)
  end

  def create_participant_manager
    @participant_manager = create(:contact, :participant_manager)
  end

  def create_local_network_guest_organization
    create(:country)
    @local_network_guest = create(:organization, name: 'Local Network Guests')
    @local_network_guest_user = create(:contact, username: 'guest',
                                               password: 'Passw0rd',
                                               organization_id: @local_network_guest.id)
  end

  def create_expelled_organization
    create_organization_and_user
    @organization.update_attribute :delisted_on, Date.current - 1.month
    @organization.update_attribute :cop_state, Organization::COP_STATE_DELISTED
    @organization.update_attribute :active, false
    @organization.update_attribute :removal_reason, RemovalReason.delisted
  end

  def create_local_network_with_report_recipient
    @local_network = create(:local_network, :with_report_recipient, name: "Canadian Local Network")
    @country = create(:country, name: "Canada", local_network: @local_network)
    @network_contact = @local_network.contacts.first
  end

  def find_or_create_role(args={})
    Role.where(name: args[:name]).first || create(:role, args)
  end

  def create_cop(organization_id, options = {})
    defaults = {
      organization_id: organization_id,
      starts_on: Date.new(2010, 01, 01),
      ends_on: Date.new(2010, 12, 31)
    }
    create(:communication_on_progress, defaults.merge(options))
  end

  def create_principle_areas
    PrincipleArea::FILTERS.values.each {|name| create(:principle_area, name: name)}
  end

  def cop_file_attributes
    attrs = build(:cop_file).attributes
    HashWithIndifferentAccess.new(attrs.merge(attachment: fixture_file_upload('files/untitled.pdf', 'application/pdf')))
  end

  def create_annual_report(params = {})
    super(valid_file_upload_attributes.merge(params))
  end

  def create_award(params = {})
    super(valid_file_upload_attributes.merge(params))
  end

  def create_meeting(params = {})
    super(valid_file_upload_attributes.merge(params))
  end

  def valid_meeting_attributes(params = {})
    super(params).merge(valid_file_upload_attributes)
  end

  def create_communication(params = {})
    super(valid_file_upload_attributes.merge(params))
  end

  def valid_communication_attributes(params = {})
    super(params).merge(valid_file_upload_attributes)
  end

  def create_integrity_measure(params = {})
    super(valid_file_upload_attributes.merge(params))
  end

  def valid_integrity_measure_attributes(params = {})
    super(params).merge(valid_file_upload_attributes)
  end

  def create_local_network_event(params = {})
    defaults = {
      attachments: [
        UploadedFile.new(
          attachment: create_file_upload,
          attachable_type: "LocalNetworkEvent"
        )
      ]
    }
    create(:local_network_event, defaults.merge(params))
  end

  def valid_local_network_event_attributes(params = {})
    super(params).merge(
      attachments: [
        {
          attachment: create_file_upload,
          attachable_type: "LocalNetworkEvent"
        }
      ]
    )
  end

  def create_file_upload
    fixture_file_upload('files/untitled.pdf', 'application/pdf')
  end

  def valid_file_upload_attributes
    {file: build(:uploaded_file)}
  end

  def valid_payload_attributes(params = {})
    data = {
      data: {
        meta_tags: {
          title: 'wow',
          description: 'sad',
          thumbnail: 'image'
        }

      }
    }

    data.merge(params)
  end

  def headline_attributes_with_taggings
    create(:country)

    country_id = Country.last.id
    issue_id = Issue.last.id
    topic_id = Topic.last.id
    sector_id = Sector.last.id

    {
      title: "UN Global Compact Launches Local Network in Canada",
      published_on: "2015-04-23",
      location: "Toronto, Ontario",
      country_id: country_id,
      description: "Global Compact Network Canada was launched in Toronto...",
      headline_type: "press_release",
      issue_ids: [issue_id],
      topic_ids: [topic_id],
      sector_ids: [sector_id]
    }
  end

  def resource_attributes_with_taggings
    issue_id = Issue.last.id
    topic_id = Topic.last.id
    sector_id = Sector.last.id

    attributes_for(:resource).merge({
      issues: [issue_id],
      topics: [topic_id],
      sectors: [sector_id]
    }).symbolize_keys
  end

  def fixture_pdf_file
    fixture_file_upload('files/untitled.pdf', 'application/pdf')
  end

  def assert_includes_error(model, message)
    refute model.valid?, "expected #{model} to not be valid"
    assert_includes model.errors.full_messages, message
  end
  
  def event_store
    Rails.configuration.x_event_store
  end

end

class ActionController::TestCase
  include Devise::TestHelpers
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Warden::Test::Helpers
  Warden.test_mode!

  teardown do
    Warden.test_reset!
  end

  def t(*args)
    I18n.t(*args)
  end

end

class JavascriptIntegrationTest < ActionDispatch::IntegrationTest

  self.use_transactional_fixtures = false

  setup do
    Capybara.asset_host = "http://localhost:3000"
    @javascript_driver = Capybara.javascript_driver
    Capybara.javascript_driver= :poltergeist
    @default_driver = Capybara.default_driver
    Capybara.default_driver = :poltergeist

    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  teardown do
    Capybara.reset!
    DatabaseCleaner.clean
    load Rails.root + File.join(".", "db", "seeds.rb")

    # Reset the tools
    Capybara.javascript_driver = @javascript_driver
    Capybara.default_driver = @default_driver
    DatabaseCleaner.strategy = :transaction
  end

end

class MockSearchResult < SimpleDelegator
  def initialize(instance=nil)
    super([instance].compact)
  end

  def total_pages
    0
  end
end

module LocalNetworkSubmodelControllerHelper

  def seeds
    Principle.create! name: "Global Compact"
    Principle.create! name: "Human Rights"
    Principle.create! name: "Labour"
    Principle.create! name: "Environment"
    Principle.create! name: "Anti-Corruption"
    Principle.create! name: 'Business and Peace'
    Principle.create! name: "Financial Markets"
    Principle.create! name: "Business for Development"
    Principle.create! name: "UN / Business Partnerships"
    Principle.create! name: "Supply Chain Sustainability"
  end

  def sign_in_as_local_network
    @contact = create_local_network_with_report_recipient
    sign_in @contact

    assert @contact.from_network?
    assert @contact.local_network == @local_network
    refute @contact.from_organization?

    seeds
  end

end
