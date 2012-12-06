ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include FixtureReplacement
  include ActionDispatch::TestProcess
  include Devise::TestHelpers

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  # Explicitly load example data
  FixtureReplacement.load_example_data

  def as(user)
    user.try(:id) ? {:user_id => user.id} : {}
  end

  def assert_redirected_to_index
    assert_redirected_to :action => 'index'
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
    @root = create_page :position => 0, :path => '/index.html'
    @parent1 = create_page :position => 0, :path => '/parent1/index.html'
    @parent2 = create_page :position => 1, :path => '/parent2/index.html'
    @child1 = create_page :parent => @parent1, :position => 0, :path => '/parent1/child1/index.html'
    @child2 = create_page :parent => @parent1, :position => 1, :path => '/parent1/child2.html'
    @sub1 = create_page :parent => @child1, :position => 0, :path => '/parent1/child1/sub1.html'
  end

  def create_new_logo_request
    create_organization_and_user
    create_ungc_organization_and_user
    create_logo_publication
    @logo_request = create_logo_request(:contact_id      => @organization_user.id,
                                        :organization_id => @organization.id)
  end

  def create_new_case_story
    create_organization_and_user
    create_ungc_organization_and_user
    @case_story = create_case_story(:contact_id      => @organization_user.id,
                                    :organization_id => @organization.id)
  end

  def create_approved_case_story
    create_new_case_story
    @case_story.comments.create(:body        => 'lorem ipsum',
                                :contact_id  => @staff_user.id,
                                :state_event => LogoRequest::EVENT_REVISE)
    @case_story.approve
  end

  def create_approved_logo_request
    create_new_logo_request
    # we need a comment before approving
    @logo_request.logo_files << create_logo_file(:zip  => fixture_file_upload('files/untitled.pdf', 'application/pdf'))
    @logo_request.logo_comments.create(:body        => 'lorem ipsum',
                                       :contact_id  => @staff_user.id,
                                       :attachment  => fixture_file_upload('files/untitled.pdf', 'application/pdf'),
                                       :state_event => LogoRequest::EVENT_REVISE)
    @logo_request.approve
  end


  def create_non_business_organization_type
    @non_business_organization_type = create_organization_type(:name => 'Academic',
                                                               :type_property => OrganizationType::NON_BUSINESS)
  end

  def create_non_business_organization_and_user(state=nil)
    create_non_business_organization_type
    create_roles
    create_organization_type(:name => 'Academic')
    create_country
    @organization = create_organization(:employees => 50,
                                        :organization_type_id => OrganizationType.academic.id)
    @organization.approve! if state == 'approved'
    @organization_user = create_contact(:organization_id => @organization.id,
                                        :role_ids        => [Role.contact_point.id])
  end

  def create_organization_and_user(state=nil)
    create_roles
    create_organization_type(:name => 'SME')
    create_country
    @organization = create_organization(:employees => 50,
                                        :organization_type_id => OrganizationType.sme.id,
                                        :cop_due_on => Date.today + 1.year)
    @organization.approve! if state == 'approved'
    @organization_user = create_contact(:organization_id => @organization.id,
                                        :role_ids        => [Role.contact_point.id])
  end

  def create_organization_and_ceo
    create_organization_and_user
    @organization_ceo = create_contact(:organization_id => @organization.id,
                                       :role_ids        => [Role.ceo.id])
  end

  def create_financial_contact
    @financial_contact = create_contact(:organization_id => @organization.id,
                                        :role_ids        => [Role.financial_contact.id])
  end

  def create_ungc_organization_and_user
    create_organization_type
    create_country
    @ungc = create_organization(:name => 'UNGC')
    @staff_user = create_contact(:username           => 'staff',
                                 :password        => 'password',
                                 :organization_id => @ungc.id)
  end

  def create_staff_user
    create_ungc_organization_and_user
    return @staff_user
  end

  def create_local_network_guest_organization
    create_organization_type
    create_country
    @local_network_guest = create_organization(:name => 'Local Network Guests')
    @local_network_guest_user = create_contact(:username           => 'guest',
                                               :password        => 'password',
                                               :organization_id => @local_network_guest.id)
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
    @local_network = create_local_network(:name => "Canadian Local Network")
    @country = create_country(:name => "Canada", :local_network_id => @local_network.id)
    @network_contact = create_contact(:local_network_id => @local_network.id,
                                      :role_ids         => [Role.network_report_recipient.id])
  end

  def create_roles
    Role::FILTERS.values.each {|name| create_role(:name => name, :description => "value")}
  end

  def create_cop(organization_id, options = {})
    defaults = {
      :organization_id => organization_id,
      :starts_on => Date.new(2010, 01, 01),
      :ends_on => Date.new(2010, 12, 31)
    }
    create_communication_on_progress(defaults.merge(options))
  end

  def create_principle_areas
    PrincipleArea::FILTERS.values.each {|name| create_principle_area(:name => name)}
  end

  def create_removal_reasons
    RemovalReason::FILTERS.values.each {|description| create_removal_reason(:description => description)}
  end

  def create_initiatives
    @lead_initiative    = create_initiative(:id => 19, :name => 'Global Compact LEAD')
    @climate_initiative = create_initiative(:id => 2,  :name => 'Caring for Climate')
  end
end
