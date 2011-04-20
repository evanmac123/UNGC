ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  include FixtureReplacement
  include AuthenticatedTestHelper

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false  

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
    create_roles
    create_organization_type(:name => 'Academic')
    create_country
    @organization = create_organization(:employees => 50,
                                        :organization_type_id => OrganizationType.academic.id)
    @organization.approve! if state == 'approved'
    @organization_user = create_contact(:organization_id => @organization.id,
                                        :email           => 'contact@example.com',
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
                                        :email           => 'contact@example.com',
                                        :role_ids        => [Role.contact_point.id])
  end

  def create_organization_and_ceo
    create_organization_and_user
    @organization_ceo = create_contact(:organization_id => @organization.id,
                                       :email           => "ceo@example.com", 
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
    @staff_user = create_contact(:login           => 'staff',
                                 :password        => 'password',
                                 :email           => 'staff@un.org',
                                 :organization_id => @ungc.id)                            
  end
  
  def create_staff_user
    create_ungc_organization_and_user
    return @staff_user
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
    @local_network = create_local_network(:name => "Canadian Local Network")
    @country = create_country(:name => "Canada", :local_network_id => @local_network.id)
    @network_contact = create_contact(:local_network_id => @local_network.id,
                                      :email            => 'network@example.com',
                                      :role_ids         => [Role.network_report_recipient.id])
  end
  
  def create_roles
    create_role(:name => 'CEO', :description => "value",  :old_id => 3)
    create_role(:name => 'Contact Point', :description => "value", :old_id => 4)
    create_role(:name => 'General Contact', :description => "value", :old_id => 9)
    create_role(:name => 'Financial Contact', :description => "value", :old_id => 2)
    create_role(:name => 'Network Report Recipient', :description => "value", :old_id => 13)
    create_role(:name => 'Website Editor', :description => "value", :old_id => 15)
  end
  
  def create_cop(organization_id)
    create_communication_on_progress(:organization_id => organization_id,
                                     :starts_on => Date.new(2010, 01, 01),
                                     :ends_on => Date.new(2010, 12, 31))
  end
  
  def create_principle_areas
    PrincipleArea::FILTERS.values.each {|name| create_principle_area(:name => name)}
  end

  def create_removal_reasons
    RemovalReason::FILTERS.values.each {|description| create_removal_reason(:description => description)}
  end
  
  def fixture_file_upload(path, mime_type = nil, binary = false)
    fixture_path = ActionController::TestCase.send(:fixture_path) if ActionController::TestCase.respond_to?(:fixture_path)
    ActionController::TestUploadedFile.new("#{fixture_path}#{path}", mime_type, binary)
  end
end
