require 'test_helper'

class NavigationTest < ActiveSupport::TestCase
  
  context "given a tree" do
    setup do
      create_simple_tree
    end

    should "see that child1 is a child of parent1" do
      assert_equal @child1.parent_id, @parent1.id
      assert @child1.is_child_of?(@parent1)
    end

    should "see that child2 is NOT a child of parent2" do
      assert !@child2.is_child_of?(@parent2)
    end
    
    should "find parent1's children" do
      assert_same_elements [@child1, @child2], @parent1.children
    end
    
    should "find no children for parent2" do
      assert_equal [], @parent2.children
    end
    
    should "find child1's children" do
      assert_same_elements [@sub1], @child1.children
    end
    
    should "find no children for child2" do
      assert_equal [], @child2.children
    end

    should "find sub1 by path" do
      assert_equal @sub1, Navigation.for_path('/parent1/child1/sub1.html')
    end
    
    should "find parent1 given a close path match" do
      assert_equal @parent1.id, Navigation.for_path('/parent1/misc_other_thing.html').id
    end

    should "find child1 given a close path match" do
      assert_equal @child1.id, Navigation.for_path('/parent1/child1/misc_other_thing.html').id
    end
  end
  
  
end
