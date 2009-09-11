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
    content = create_content(options)
    content.versions.first.approve!
    content
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
    create_logo_publication
    @logo_request = create_logo_request
  end

  def create_organization_user
    @organization = create_organization
    @organization_user = create_contact(:organization_id => @organization.id)
  end
  
  def create_ungc_organization
    @ungc = create_organization(:name => 'UNGC')
    @staff_user = create_contact(:login           => 'staff',
                                 :organization_id => @ungc.id)
  end
end
