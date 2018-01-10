require "test_helper"

class ExploreOurLibraryPageTest < ActiveSupport::TestCase

  test "resources are show in the specified order" do
    second = create(:resource, title: "second")
    third = create(:resource, title: "third")
    first = create(:resource, title: "first")

    container = create(:container)

    data = {
        featured: [
            {resource_id: first.id},
            {resource_id: second.id},
            {resource_id: third.id},
        ]
    }

    page = ExploreOurLibraryPage.new(container, data)

    expected_order = %w(first second third)
    assert_equal expected_order, page.featured.map(&:title)
  end

end
