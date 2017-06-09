require "test_helper"

module ActionPlatform
  class PlatformTest < ActiveSupport::TestCase

    test "validate presence of a name" do
      platform = build(:action_platform_platform, :name => nil)

      assert_not platform.save
    end

    test "validate presence of a description" do
      platform = build(:action_platform_platform, :description => nil)

      assert_not platform.save
    end

    test "validate presence of a slug" do
      platform = build(:action_platform_platform, :slug => nil)

      assert_not platform.save
    end

    test "destroy destroys all children" do
      platform = create(:action_platform_platform)
      create_list(:action_platform_subscription, 5, :platform => platform)

      another_platform = create(:action_platform_platform)
      other_subscriptions = create_list(:action_platform_subscription, 3, :platform => another_platform)

      assert_equal 2, ActionPlatform::Platform.count
      assert_equal 8, ActionPlatform::Subscription.count

      platform.destroy

      assert_equal 1, ActionPlatform::Platform.count
      assert_equal 3, ActionPlatform::Subscription.count

      assert_equal other_subscriptions, another_platform.subscriptions
    end

  end
end
