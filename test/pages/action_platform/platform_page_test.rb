require "test_helper"

class ActionPlatform::PlatformPageTest < ActiveSupport::TestCase

  test "#title" do
    platform = build(:action_platform_platform)
    page = ActionPlatform::PlatformPage.new(platform)

    assert_equal platform.name, page.title
    assert_equal platform.name, page.meta_title
    assert_nil page.meta_description
    assert_equal platform.description, page.description
    assert_equal platform.name, page.hero.dig(:title, :title1)
  end

  test "#handles empty description" do
    platform = build(:action_platform_platform, description: nil)
    page = ActionPlatform::PlatformPage.new(platform)

    assert_equal "", page.description
  end

end
