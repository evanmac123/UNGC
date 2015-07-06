require 'test_helper'
require 'pages/pages_test_helper'

class Components::SectionNavTest < ActiveSupport::TestCase
  include PagesTestHelper

  context 'with data' do
    setup do
      @p = create_container_with_payload('/parent-path', 'parent title')
      @c = create_container_with_payload('/test-path', 'test title', parent: @p)
      create_container_with_payload('/child-path-1', 'child title 1', parent: @c)
      @subject = Components::SectionNav.new(@c)
    end

    should 'have the correct path and title for current element' do
      assert_equal '/parent-path/test-path', @subject.current.path
      assert_equal 'test title', @subject.current.title
    end

    should 'have the correct path and title for parent element' do
      assert_equal '/parent-path', @subject.parent.path
      assert_equal 'parent title', @subject.parent.title
    end

    should 'have the correct path and title for child element' do
      assert_equal '/parent-path/test-path/child-path-1', @subject.children.first.path
      assert_equal 'child title 1', @subject.children.first.title
    end

    should 'sort children lexicographically ' do
      create_container_with_payload('/a', 'a', parent: @c)
      create_container_with_payload('/child-path-3', 'child title 3', parent: @c)
      create_container_with_payload('/child-path-0', 'child title 0', parent: @c)
      Redesign::Container.update_all sort_order: 0
      assert_equal '/parent-path/test-path/child-path-3', @subject.children.last.path
      assert_equal 'child title 3', @subject.children.last.title
    end

    should 'sort siblings lexicographically ' do
      create_container_with_payload('/a', 'a', parent: @p)
      create_container_with_payload('/zibling-path-3', 'zibling title 3', parent: @p)
      create_container_with_payload('/sibling-path-0', 'sibling title 0', parent: @p)
      Redesign::Container.update_all sort_order: 0
      assert_equal '/parent-path/zibling-path-3', @subject.siblings.last.path
      assert_equal 'zibling title 3', @subject.siblings.last.title
    end

    should 'sort children with sort_order if set ' do
      create_container_with_payload('/a', 'a', parent: @c)
      create_container_with_payload('/child-path-3', 'child title 3', parent: @c)
      create_container_with_payload('/child-path-0', 'child title 0', parent: @c)
      c = create_container_with_payload('/child-path-4', 'child title 4', parent: @c)
      Redesign::Container.update_all sort_order: 0
      c.update_attribute :sort_order_position, :first
      assert_equal '/parent-path/test-path/child-path-4', @subject.children.first.path
      assert_equal 'child title 4', @subject.children.first.title
      assert_equal '/parent-path/test-path/child-path-3', @subject.children.last.path
      assert_equal 'child title 3', @subject.children.last.title
    end

  end
end
