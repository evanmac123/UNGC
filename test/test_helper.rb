ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  include FixtureReplacement

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false  

  def create_simple_tree
    @parent1 = create_navigation :position => 0, :href => '/parent1/index.html'
    @parent2 = create_navigation :position => 1, :href => '/parent2/index.html'
    @child1 = create_navigation :parent => @parent1, :position => 0, :href => '/parent1/child1/index.html'
    @child2 = create_navigation :parent => @parent1, :position => 1, :href => '/parent1/child2.html'
    @sub1 = create_navigation :parent => @child1, :position => 0, :href => '/parent1/child1/sub1.html'
  end
end
