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

  def create_organization_and_user(state=nil)
    create_roles
    create_organization_type
    create_country
    @organization = create_organization 
    @organization.approve! if state == 'approved'
    @organization_user = create_contact(:organization_id => @organization.id,
                                        :role_ids        => [Role.contact_point.id])
  end

  def create_organization_and_ceo
    create_organization_and_user
    @organization_ceo = create_contact(:organization_id => @organization.id,
                                       :role_ids        => [Role.ceo.id])                                        
  end
  
  def create_staff_user
    create_ungc_organization_and_user
    return @staff_user
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
  
  def create_local_network_with_report_recipient
    @local_network = create_local_network(:name => "Canadian Local Network")
    @country = create_country(:name => "Canada", :local_network_id => @local_network.id)
    @network_contact = create_contact(:local_network_id => @local_network.id,
                                      :email            => 'network@example.com',
                                      :role_ids         => [Role.network_report_recipient.id])
  end
  
  def create_roles
    # creating roles for ceo and contact point
    create_role(:name => 'CEO', :old_id => 3)
    create_role(:name => 'Contact Point', :old_id => 4)
    create_role(:name => 'General Contact', :old_id => 9)
    create_role(:name => 'Network Report Recipient', :old_id => 13)
  end
  
  def create_cop(organization_id)
    create_communication_on_progress(:organization_id => organization_id)
  end
  
  def create_principle_areas
    PrincipleArea::FILTERS.values.each {|name| create_principle_area(:name => name)}
  end
  
  def fixture_file_upload(path, mime_type = nil, binary = false)
    fixture_path = ActionController::TestCase.send(:fixture_path) if ActionController::TestCase.respond_to?(:fixture_path)
    ActionController::TestUploadedFile.new("#{fixture_path}#{path}", mime_type, binary)
  end
end
