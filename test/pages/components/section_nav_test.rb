require 'test_helper'
require 'pages/pages_test_helper'

class Components::SectionNavTest < ActiveSupport::TestCase
  include PagesTestHelper

  context 'with data' do
    setup do

      p = create_container_with_payload('/parent-path', 'parent title')
      c = create_container_with_payload('/test-path', 'test title', parent: p)
      create_container_with_payload('/child-path-1', 'child title 1', parent: c)
      @subject = Components::SectionNav.new(c)
    end

    should 'have the correct path and title for current element' do
      assert_equal '/test-path', @subject.current.url
      assert_equal 'test title', @subject.current.title
    end

    should 'have the correct path and title for parent element' do
      assert_equal '/parent-path', @subject.parent.url
      assert_equal 'parent title', @subject.parent.title
    end

    should 'have the correct path and title for child element' do
      assert_equal '/child-path-1', @subject.children.first.url
      assert_equal 'child title 1', @subject.children.first.title
    end

  end
end

