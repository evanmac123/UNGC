require 'test_helper'
require 'pages/pages_test_helper'

class Components::RelatedContentTest < ActiveSupport::TestCase
  include PagesTestHelper

  context 'with containers' do
    setup do
      create_container_with_payload('/test-path', 'test title')
      create_container_with_payload('/test-path2', 'test title 2')
      create_container_with_payload('/test-path3', 'test title 3')
      data = {
        title: 'test title',
        content_boxes: [
          {container_path: '/test-path'},
          {container_path: '/test-path2'},
          {container_path: '/test-path3'}
        ]
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
      assert_equal 'No label', @subject.boxes.first.issue
    end
  end

  context 'with events' do
    setup do
      e1 = create_event(title: 'event1')
      e2 = create_event(title: 'event2')
      e3 = create_event(title: 'event3')
      data = {
        title: 'test title',
        content_boxes: [
          {container_path: Rails.application.routes.url_helpers.event_path(e1)},
          {container_path: Rails.application.routes.url_helpers.event_path(e2)},
          {container_path: Rails.application.routes.url_helpers.event_path(e3)},
        ]
      }
      @subject = Components::RelatedContent.new(data)
    end

    should 'prepare the correct data for the presenter' do
      assert_equal 'event1', @subject.boxes.first.title
    end

    should 'should associate the correct label' do
      assert_equal 'Open', @subject.boxes.first.issue
    end
  end

  context 'with events and containers' do
    setup do
      create_container_with_payload('/test-path', 'test title')
      e2 = create_event(title: 'event2')
      create_container_with_payload('/test-path3', 'test title 3')
      data = {
        title: 'test title',
        content_boxes: [
          {container_path: '/test-path'},
          {container_path: Rails.application.routes.url_helpers.event_path(e2)},
          {container_path: '/test-path3'},
        ]
      }
      @subject = Components::RelatedContent.new(data)
    end

    should 'have the boxes in the right order' do
      assert_equal 'test title', @subject.boxes[0].title
      assert_equal 'event2', @subject.boxes[1].title
      assert_equal 'test title 3', @subject.boxes[2].title
    end
  end
end
