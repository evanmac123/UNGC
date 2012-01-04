require 'test_helper'

class PageTest < ActiveSupport::TestCase
  def latest_version(page=nil)
    page ||= @page
    page.versions(:reload).last
  end

  context "given a page" do
    setup do
      @page = create_page :content => "<p>This is my content.</p>", :approval => 'pending'
      @page.approve!
    end

    should "auto-create first version" do
      assert_equal 1, @page.versions.count
      assert_equal "<p>This is my content.</p>", @page.versions.first.content
    end

    context "with another version" do
      setup do
        @version2 = @page.new_version :content => "<p>Middle version.</p>"
        @version2.approve!
      end

      should "make version1 'previously'" do
        assert_equal 'previously', @page.reload.approval
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

        context "and the latest one is approved" do
          setup do
            assert @version3.approve!
          end

          should "revoke previous approval" do
            assert @version2.reload.previously?
          end
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

  context "given a new page" do
    setup do
      # default_page starts as approved, but we want to test approval
      @page = Page.new(:title => 'New Page')
    end

    context "and its parent" do
      setup do
        @section = create_page_group :path_stub => 'ThisIsMyPath'
        @page.group_id = @section.id
      end

      should "be able to derive it's path" do
        assert @page.save
        @page.reload
        assert_equal @page.path, '/ThisIsMyPath/new_page.html'
      end

      context "and that page has a subpage" do
        setup do
          @page.save
          @subpage = new_page :title => "I'm a sub-page", :path => nil # need to override the factory
          @subpage.parent_id = @page.id
        end

        should "be able to derive the subpage path" do
          assert @subpage.save
          @subpage.reload
          assert_equal @subpage.path, '/ThisIsMyPath/new_page/i_m_a_sub_page.html'
        end
      end
    end

    context "and it is containing index.html and that page's subpage" do
      setup do
        @page = new_page(:title => 'New Area', :path => '/NewSection/NewArea/index.html')
        @page.save
        @subpage = new_page :title => 'New Subpage', :path => nil # must override factory
        @subpage.parent_id = @page.id
      end

      should "derive a path without /index/" do
        assert @subpage.save
        @subpage.reload
        assert_equal '/NewSection/NewArea/new_subpage.html', @subpage.path
      end
    end

    context "and it is saved" do
      setup do
        @page.save
      end

      should "start out as pending" do
        assert @page.pending?
      end

      context "and it's approved" do
        setup do
          assert @page.approve!
        end

        should "save time data on page" do
          now = Time.now
          assert !@page.approved_at.nil?
          assert (now - @page.approved_at) <= 5
        end

        should "be approved" do
          assert @page.approved?
        end
      end
    end
  end

  context "given a mix of variously approved pages" do
    setup do
      @group   = create_page_group
      @page1   = create_page section: @group, path: '/path/to/page1.html' # will start approved
      @page1v2 = @page1.new_version title: 'I am new'
      @page1v2.approve!
      @page1v3 = @page1v2.new_version title: 'I am newest'
      @page2   = create_page section: @group, path: '/path/to/page2.html', approval: 'pending'
    end

    should "find appropriate versions for treeview via leaves" do
      assert_same_elements [@page1v3, @page2], @group.leaves[nil]
    end
  end

  context "given a page with a path and several versions" do
    setup do
      @group   = create_page_group
      @page1   = create_page section: @group, path: '/path/to/page1.html' # will start approved
      @page1v2 = @page1.new_version title: 'I am new'
      @page1v2.approve!
      @page1v3 = @page1v2.new_version title: 'I am newest'
      @page2   = create_page path: '/this/does_not/clash.html'
    end

    context "and the new path collides with an existing path" do
      setup do
        @changes = {path: '/this/new/path/here.html', title: 'I have a changed path'}
        @page2 = create_page path: @changes[:path]
      end

      should "check if path can be changed" do
        assert !@page1v3.wants_to_change_path_and_can?(path: @changes[:path])
        assert @page1v3.wants_to_change_path_and_can?(path: '/this/path/does_not/clash.html')
      end

      should "raise an exception and leave pages unchanged" do
        assert_raise(Page::PathCollision) { @page1v3.update_pending_or_new_version(@changes) }
        [@page1, @page1v2, @page1v3].each do |page|
          reloaded = page.reload
          assert_equal reloaded.title, page.title
          assert_equal reloaded.path, page.path
          assert page.change_path.nil?, 'Change page is nil because of collision' if page.id == @page1v3.id
        end
      end
    end

    context "and the path and other attributes are changed" do
      setup do
        @changes = {path: '/this/new/path/here.html', title: 'I have a changed path'}
        @page2 = create_page path: '/no/worries/I/dont/collide.html'
      end

      should "change title, leaving path alone, but setting change_path for later approval" do
        assert_no_difference('Page.count') { @page1v3.update_pending_or_new_version(@changes) }
        [@page1, @page1v2].each do |page|
          reloaded = page.reload
          assert_equal reloaded.path, @page1.path, "Old versions have old path"
          assert_equal reloaded.title, page.title, "Title hasn't changed here"
        end
        reloaded = @page1v3.reload
        assert_equal reloaded.change_path, @changes[:path], "Reloaded's path change is pending"
        assert_equal reloaded.path, @page1v3.path, "Reloaded's path change is pending, still has old path"
        assert_equal @changes[:title], reloaded.title
      end

      context "and the new version is approved" do
        setup do
          @page1v3.update_pending_or_new_version(@changes)
          @page1v3.reload # needs to be refreshed in between to see path changes, won't happen in real app
          assert @page1v3.approve!
        end

        should "update all page1's paths" do
          [@page1, @page1v2, @page1v3].each do |page|
            reloaded = page.reload
            assert reloaded.change_path.nil?
            assert_equal @changes[:path], reloaded.path, "Path for #{page.id} should be #{@changes[:path]} instead of #{page.path}"
          end
        end

        should "have only one approved version of the page" do
          assert_equal 1, Page.all_versions_of(@changes[:path]).with_approval('approved').size, "Should only be one approved version for this path"
        end
      end

    end
  end

  context "given a page with children" do
    setup do
      @parent = create_page
      attrs = new_page.attributes.merge(parent_id: @parent.id)
      @child1 = Page.create(attrs)
      @child2 = Page.create(attrs)
      @child3 = Page.create(attrs)
      @pending = @parent.update_pending_or_new_version(title: "I am new")
    end

    should "not have children attached to pending" do
      assert_equal 0, @pending.children.size
    end

    context "when pending is approved" do
      setup do
        @pending.approve!
      end

      should "move children to new version" do
        assert_equal 3, @pending.children.size
      end
    end

  end

end
