require 'test_helper'
require 'pages/pages_test_helper'

class Components::RelatedContentTest < ActiveSupport::TestCase
  include PagesTestHelper

  context 'with data' do
    setup do

      create_container_with_payload('/test-path', 'test title')
      create_container_with_payload('/test-path2', 'test title 2')
      create_container_with_payload('/test-path3', 'test title 3')
      data = {
        related_content: {
          title: 'test title',
          content_boxes: [
            {container_path: '/test-path'},
            {container_path: '/test-path2'},
            {container_path: '/test-path3'}
          ]
        }
      }
      @subject = Components::RelatedContent.new(data)
    end

    should 'prepare the correct data for the presenter' do
      assert_equal 'test title', @subject.boxes.first.title
    end

    should 'should have the proper title' do
      assert_equal @subject.title, 'test title'
    end

    should 'should associate the correct label' do
      # TODO
    end

  end
end
