ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  include FixtureReplacement
  include AuthenticatedTestHelper

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false  

  def assert_layout(layout)
    assert_equal "layouts/#{layout}", @response.layout
  end
  
  def create_approved_content(options)
    create_default_template
    content = create_content(options)
    content.versions.first.approve!
    content
  end

  def create_default_template
    ContentTemplate.create(:filename => 'pages/static.html.haml', :label => 'Standard', :default => true)
  end

  def create_simple_tree
    @root = create_navigation :position => 0, :href => '/index.html'
    @parent1 = create_navigation :position => 0, :href => '/parent1/index.html'
    @parent2 = create_navigation :position => 1, :href => '/parent2/index.html'
    @child1 = create_navigation :parent => @parent1, :position => 0, :href => '/parent1/child1/index.html'
    @child2 = create_navigation :parent => @parent1, :position => 1, :href => '/parent1/child2.html'
    @sub1 = create_navigation :parent => @child1, :position => 0, :href => '/parent1/child1/sub1.html'
  end
  
  def create_new_logo_request
    create_organization_user
    create_ungc_organization
    create_logo_publication
    @logo_request = create_logo_request(:contact_id      => @organization_user.id,
                                        :organization_id => @organization.id)
  end
  
  def create_new_case_story
    create_organization_user
    create_ungc_organization
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

  def create_organization_user
    create_organization_type
    @organization = create_organization
    @organization_user = create_contact(:organization_id => @organization.id,
                                        :email           => 'email@example.com')
  end
  
  def create_staff_user
    create_organization_type
    un = create_ungc_organization
    create_contact(:organization_id => un.id)
  end

  def create_ungc_organization
    @ungc = create_organization(:name => 'UNGC')
    @staff_user = create_contact(:login           => 'staff',
                                 :organization_id => @ungc.id)
  end
  
  def fixture_file_upload(path, mime_type = nil, binary = false)
    fixture_path = ActionController::TestCase.send(:fixture_path) if ActionController::TestCase.respond_to?(:fixture_path)
    ActionController::TestUploadedFile.new("#{fixture_path}#{path}", mime_type, binary)
  end
end
