require "test_helper"

module ActionPlatform
  class PlatformTest < ActiveSupport::TestCase

    test "validate name" do
      platform = build(:action_platform_platform, :name => nil)

      assert_not platform.valid?
      assert_equal platform.errors[:name], ["can't be blank"]

      too_long_255 = Faker::Lorem.characters(256)

      platform.name = too_long_255

      assert_not platform.valid?
      assert_equal platform.errors[:name], ['is too long (maximum is 255 characters)']
    end

    test "validate presence of a description" do
      platform = build(:action_platform_platform, :description => nil)

      assert_not platform.save
    end

    test "validate length of a description" do
      too_long_5000 = Faker::Lorem.characters(5_001)

      platform = build(:action_platform_platform, :description => too_long_5000)

      assert_not platform.valid?, 'platform is valid'

      assert_equal platform.errors[:description], ['is too long (maximum is 5000 characters)']
    end

    test "validate presence of a slug" do
      platform = build(:action_platform_platform, :slug => nil)

      assert_not platform.save
    end

    test "fails if children exist" do
      platform = create(:action_platform_platform)
      create_list(:action_platform_subscription, 5, :platform => platform)

      another_platform = create(:action_platform_platform)
      other_subscriptions = create_list(:action_platform_subscription, 3, :platform => another_platform)

      assert_equal 2, ActionPlatform::Platform.count
      assert_equal 8, ActionPlatform::Subscription.count

      platform.destroy

      assert_equal platform.errors[:base], ["Cannot delete record because dependent subscriptions exist"]
      assert_equal 2, ActionPlatform::Platform.count
      assert_equal 8, ActionPlatform::Subscription.count

      assert_equal other_subscriptions, another_platform.subscriptions
    end

  end
end
