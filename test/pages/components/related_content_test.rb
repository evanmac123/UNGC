require 'test_helper'

class Components::RelatedContentTest < ActiveSupport::TestCase
  context 'with data' do
    setup do
      c = Redesign::Container.create({
        slug: '/test-path',
        path: '/test-path',
        layout: :home
      })

      p = Redesign::Payload.create({
        container_id: c.id,
        data: {
          meta_tags: {
            title: 'test title',
            description: 'test_description',
            thumbnail: 'http://img.com/1',
          }
        }
      })

      c.public_payload = p
      c.save

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
