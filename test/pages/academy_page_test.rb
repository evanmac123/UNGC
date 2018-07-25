# frozen_string_literal: true

require "test_helper"

class AcademyPageTest < ActiveSupport::TestCase

  test "Accordion can nest 2 levels deep" do
    payload = create(:payload, data: {
      accordion: {
        title: "accordion",
        blurb: "blurb",
        items: [
          {
            title: "item1",
            content: "item1content",
            children: [
              {
                title: "item1.1",
                content: "item1.1 contact"
              }
            ]
          }
        ]
      }
    })

    page = AcademyPage.new(payload.container, payload.data)
    assert_equal "item1.1", page.accordion.items.first.children.first.title
  end

end
