require 'test_helper'

class PageTest < ActiveSupport::TestCase
  def latest_version(page=nil)
    page ||= @page
    page.versions(:reload).last
  end
  
  context "given a page" do
    setup do
      @page = create_page :content => "<p>This is my content.</p>", :approval => 'pending'
    end

    should "auto-create first version" do
      assert_equal 1, @page.versions.count
      assert_equal "<p>This is my content.</p>", @page.versions.first.content
    end
    
    context "with another version" do
      setup do
        @version2 = @page.new_version :content => "<p>Middle version.</p>", :approval => 'approved'
      end

      should "auto-increment version number" do
        assert_equal 2, @version2.version_number
      end

      should "find one active version, version2" do
        assert_equal @version2, @page.active_version
      end

      context "with three versions" do
        setup do
          @version1 = @page.versions.first
          @version3 = @version2.new_version :content => "<p>Latest version.</p>"
          @active   = Page.approved_for_path(@page.path)
        end

        should "find version1 for previous_version" do
          assert_equal @version1, @active.previous_version
        end
        
        should "find version3 for next_version" do
          assert_equal @version3, @active.next_version
        end
        
        should "find version2 for version1.next_version" do
          assert_equal @version2, @version1.next_version
        end
        
        should "find version2 for version3.previous_version" do
          assert_equal @version2, @version3.previous_version
        end
        
        should "find nil for version3.next_version" do
          assert_equal nil, @version3.next_version
        end
        
        should "find nil for version1.previous_version" do
          assert_equal nil, @version1.previous_version
        end
      end
    end
  end
  
  context "given a tree" do
    setup do
      create_simple_tree
      # '/index.html'
      # '/parent1/index.html'
      # '/parent2/index.html'
      # '/parent1/child1/index.html'
      # '/parent1/child2.html'
      # '/parent1/child1/sub1.html'
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
      assert_equal @sub1, Page.find_navigation_for('/parent1/child1/sub1.html')
    end
    
    should "find parent1 given a close path match" do
      assert_equal @parent1, Page.find_navigation_for('/parent1/misc_other_thing.html')
    end

    should "find child1 given a close path match" do
      assert_equal @child1, Page.find_navigation_for('/parent1/child1/misc_other_thing.html')
    end
  end
  
  
  
end
