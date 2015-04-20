require 'simplecov'
SimpleCov.start

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'
require 'mocha/setup'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include FixtureReplacement
  include ActionDispatch::TestProcess

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  # Explicitly load example data
  FixtureReplacement.load_example_data

  def as(user)
    user.try(:id) ? {user_id: user.id} : {}
  end

  def assert_redirected_to_index
    assert_redirected_to action: 'index'
  end

  def assert_layout(layout)
    assert_equal "layouts/#{layout}", @response.layout
  end

  def create_approved_content(options)
    create_page(options)
  end

  def create_approved_page(options)
    create_page(options)
  end

  def create_simple_tree
    @root = create_page position: 0, path: '/index.html'
    @parent1 = create_page position: 0, path: '/parent1/index.html'
    @parent2 = create_page position: 1, path: '/parent2/index.html'
    @child1 = create_page parent: @parent1, position: 0, path: '/parent1/child1/index.html'
    @child2 = create_page parent: @parent1, position: 1, path: '/parent1/child2.html'
    @sub1 = create_page parent: @child1, position: 0, path: '/parent1/child1/sub1.html'
  end

  def create_new_logo_request
    create_organization_and_user
    create_ungc_organization_and_user
    create_logo_publication
    @logo_request = create_logo_request(contact_id: @organization_user.id,
                                        organization_id: @organization.id)
  end

  def create_new_case_story
    create_organization_and_user
    create_ungc_organization_and_user
    @case_story = create_case_story(contact_id: @organization_user.id,
                                    organization_id: @organization.id)
  end

  def create_approved_case_story
    create_new_case_story
    @case_story.comments.create(body: 'lorem ipsum',
                                contact_id: @staff_user.id,
                                state_event: LogoRequest::EVENT_REVISE)
    @case_story.approve
  end

  def create_approved_logo_request
    create_new_logo_request
    # we need a comment before approving
    @logo_request.logo_files << create_logo_file(zip: fixture_file_upload('files/untitled.pdf', 'application/pdf'))
    @logo_request.logo_comments.create(body: 'lorem ipsum',
                                       contact_id: @staff_user.id,
                                       attachment: fixture_file_upload('files/untitled.pdf', 'application/pdf'),
                                       state_event: LogoRequest::EVENT_REVISE)
    @logo_request.approve
  end


  def create_non_business_organization_type
    @non_business_organization_type = create_organization_type(name: 'Academic',
                                                               type_property: OrganizationType::NON_BUSINESS)
  end

  def create_non_business_organization_and_user(state=nil)
    create_non_business_organization_type
    create_roles
    create_organization_type(name: 'Academic')
    create_country
    @organization = create_organization(employees: 50,
                                        country: Country.first,
                                        organization_type_id: OrganizationType.academic.id)
    @organization.approve! if state == 'approved'
    @organization_user = create_contact(organization_id: @organization.id,
                                        role_ids: [Role.contact_point.id])
  end

  def create_organization_and_user(state=nil)
    create_roles
    create_organization_type(name: 'SME')
    create_country
    sector = create_sector
    listing_status = create_listing_status
    @organization = create_organization(employees: 50,
                                        organization_type_id: OrganizationType.sme.id,
                                        country: Country.first,
                                        sector: sector,
                                        listing_status: listing_status,
                                        cop_due_on: Date.today + 1.year)
    @organization.approve! if state == 'approved'
    @organization_user = create_contact(organization_id: @organization.id,
                                        role_ids: [Role.contact_point.id])
  end

  def create_organization_and_ceo
    create_organization_and_user
    @organization_ceo = create_contact(organization_id: @organization.id,
                                       role_ids: [Role.ceo.id])
  end

  def create_approved_organization_and_user
      create_organization_and_user
      @organization.approve!
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
    @financial_contact = create_contact(organization_id: @organization.id,
                                        role_ids: [Role.financial_contact.id])
  end

  def create_ungc_organization_and_user
    create_organization_type
    create_country
    @ungc = create_organization(name: 'UNGC')
    @staff_user = create_contact(username: 'staff',
                                 password: 'password',
                                 organization_id: @ungc.id)
  end

  def create_staff_user
    create_ungc_organization_and_user
    return @staff_user
  end

  def create_participant_manager
    @participant_manager = create_contact
    @participant_manager.roles << Role.participant_manager
    @participant_manager
  end

  def create_local_network_guest_organization
    create_organization_type
    create_country
    @local_network_guest = create_organization(name: 'Local Network Guests')
    @local_network_guest_user = create_contact(username: 'guest',
                                               password: 'password',
                                               organization_id: @local_network_guest.id)
  end

  def create_expelled_organization
    create_organization_and_user
    create_removal_reasons
    @organization.update_attribute :delisted_on, Date.today - 1.month
    @organization.update_attribute :cop_state, Organization::COP_STATE_DELISTED
    @organization.update_attribute :active, false
    @organization.update_attribute :removal_reason_id, RemovalReason.delisted.id
  end

  def create_local_network_with_report_recipient
    create_roles
    @local_network = create_local_network(name: "Canadian Local Network")
    @country = create_country(name: "Canada", local_network_id: @local_network.id)
    @network_contact = create_contact(local_network_id: @local_network.id,
                                      role_ids: [Role.network_report_recipient.id])
  end

  def find_or_create_role(args={})
    Role.where(name: args[:name]).first || create_role(args)
  end

  def create_roles
    Role::FILTERS.values.each {|name| find_or_create_role(:name => name, :description => "value")}
  end

  def create_cop(organization_id, options = {})
    defaults = {
      organization_id: organization_id,
      starts_on: Date.new(2010, 01, 01),
      ends_on: Date.new(2010, 12, 31)
    }
    create_communication_on_progress(defaults.merge(options))
  end

  def create_principle_areas
    PrincipleArea::FILTERS.values.each {|name| create_principle_area(name: name)}
  end

  def create_removal_reasons
    RemovalReason::FILTERS.values.each {|description| create_removal_reason(description: description)}
  end

  def create_initiatives
    @lead_initiative    = create_initiative(id: 19, name: 'Global Compact LEAD')
    @climate_initiative = create_initiative(id: 2,  name: 'Caring for Climate')
  end

  def cop_file_attributes
    HashWithIndifferentAccess.new(valid_cop_file_attributes.merge(attachment: fixture_file_upload('files/untitled.pdf', 'application/pdf')))
  end

  def create_annual_report(params = {})
    super(valid_file_upload_attributes.merge(params))
  end

  def create_award(params = {})
    super(valid_file_upload_attributes.merge(params))
  end

  def create_mou(params = {})
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
    super(defaults.merge(params))
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
    {file: create_file_upload}
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

  def create_issue_hierarchy(tree = nil)
    if tree.nil?
      tree = [
        ["Issue A", [
          "Issue 1",
          "Issue 2",
          "Issue 3",
        ]],
        ["Issue B", [
          "Issue 4",
          "Issue 5",
          "Issue 6",
        ]]
      ]
    end

    tree.map do |parent_name, child_names|
      issue_area = create_issue_area(name: parent_name)
      child_names.map do |child_name|
        create_issue(name: child_name, issue_area: issue_area)
      end
      issue_area
    end

  end

  def create_topic_hierarchy(tree = nil)
    if tree.nil?
      tree = [
        ["Topic A", [
          "Topic 1",
          "Topic 2",
          "Topic 3",
        ]],
        ["Topic B", [
          "Topic 4",
          "Topic 5",
          "Topic 6",
        ]]
      ]
    end

    tree.map do |parent_name, child_names|
      parent = create_topic(name: parent_name)
      child_names.map do |child_name|
        parent.children << create_topic(name: child_name, parent: parent)
      end
      parent.tap {|p| p.save!}
    end

  end

  def create_sector_hierarchy
    tree = [
        ["Sector A", [
          "Sector 1",
          "Sector 2",
          "Sector 3",
        ]],
        ["Sector B", [
          "Sector 4",
          "Sector 5",
          "Sector 6",
        ]]
      ]

    tree.map do |group_name, child_names|
      parent = create_sector name: group_name
      child_names.each_with_index.map do |child_name, i|
        create_sector(
          name: child_name,
          parent: parent,
          icb_number: i
        )
      end
      parent
    end
  end

end

class ActionController::TestCase
  include Devise::TestHelpers
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Warden::Test::Helpers
  Warden.test_mode!
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

