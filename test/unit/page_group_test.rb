require 'test_helper'

class PageGroupTest < ActiveSupport::TestCase
  
  context "given some page groups" do
    setup do
      @group1 = create_page_group
      @group2 = create_page_group
      @hidden = create_page_group :display_in_navigation => false
    end

    should "fail to show @hidden in navigation" do
      assert_same_elements [@group1, @group2], PageGroup.for_navigation
    end
    
    context "and some pages are assigned" do
      setup do
        @group1_pages, @group2_pages, @hidden_pages = [], [], []
        @group1_pages << create_page(:section => @group1)
        @group1_pages << create_page(:section => @group1)
        @group1_pages << create_page(:section => @group1)
        @group2_pages << create_page(:section => @group2)
        @group2_pages << create_page(:section => @group2)
        @hidden_pages << create_page(:section => @hidden, :display_in_navigation => true)
        create_page :parent =>  @group1_pages.first
      end

      should "find children for group1" do
        assert_same_elements @group1_pages, @group1.children
      end

      should "find children for group2" do
        assert_same_elements @group2_pages, @group2.children
      end
      
      should "forward group#path to first child" do
        assert_equal @group1_pages.first.path, @group1.path
      end
    end

    context "and a new folder is created with a name" do
      setup do
        @new_group = PageGroup.create name: 'New folder'
      end

      should "automatically position at end of list" do
        assert reloaded = @new_group.reload
        assert_equal 4, reloaded.position
      end
    end
  end
  
end
