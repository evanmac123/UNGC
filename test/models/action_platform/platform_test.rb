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

    context "validate default start/end dates" do
      should "allow both to be null" do
        platform = build(:action_platform_platform, default_starts_at: '', default_ends_at: '')

        assert platform.valid?, 'Platform not valid with blank default start/end dates'
      end

      should "not allow one to be null" do
        platform = build(:action_platform_platform, default_starts_at: '')
        assert_not platform.valid?, platform.errors.full_messages
        assert_equal platform.errors[:default_ends_at],
                     ["must be after Platform subscription year default starts at"]


        platform = build(:action_platform_platform, default_ends_at: '')
        assert_not platform.valid?, platform.errors.full_messages
        assert_equal platform.errors[:default_ends_at],
                     ["must be after Platform subscription year default starts at"]
      end

      should "validate that ends_at is after starts_at" do
        platform = build(:action_platform_platform, default_starts_at: Date.current, default_ends_at: 1.day.ago)

        assert_not platform.valid?, "default end date is before start_date"
        assert_equal platform.errors[:default_ends_at], ["must be after Platform subscription year default starts at"]

        platform.default_ends_at = platform.default_starts_at
        assert_not platform.valid?, "default end date the same as start_date"
      end
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
