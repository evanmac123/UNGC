require "test_helper"

class AboutFoundationPageTest < ActiveSupport::TestCase

  test "adds a call to action" do
    payload = build_stubbed(:payload)
    container = build_stubbed(:container, public_payload: payload, layout: :article)
    page = AboutFoundationPage.new(container, payload.data, "/some-url")

    assert_includes page.sidebar_widgets.calls_to_action, {
      label: "Contribute by Credit Card",
      external: false,
      url: "/some-url"
    }
  end

end
