require 'test_helper'
require 'pages/pages_test_helper'

class Components::RelatedContentTest < ActiveSupport::TestCase
  include PagesTestHelper

  context 'with data' do
    setup do

      create_container_with_payload('/test-path', 'test title')
      data = {
        related_content: [
          {container_path: '/test-path'}
        ]
      }
      @subject = Components::RelatedContent.new(data)
    end

    should 'prepare the correct data for the presenter' do
      assert_equal @subject.data, [{
        thumbnail: 'http://img.com/1',
        issue: "no issue",
        url: '/test-path',
        title: 'test title'
      }]
    end

    should 'associate the first issue if available' do
      # TODO
    end

  end
end
