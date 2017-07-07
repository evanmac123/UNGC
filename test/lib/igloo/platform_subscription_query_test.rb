require "test_helper"

module Igloo
  class PlatformSubscriptionQueryTest < ActiveSupport::TestCase

    test "includes active subscribers" do
      subscriber = create(:contact)
      create(:action_platform_subscription, contact: subscriber, status: :approved)

      query = Igloo::PlatformSubscriptionQuery.new
      assert query.include?(subscriber), "subscribers should be included"
    end

    test "does not include non-subscribers" do
      contact = create(:contact)

      query = Igloo::PlatformSubscriptionQuery.new
      assert_not query.include?(contact)
    end

    test "does not include inactive subscribers" do
      subscriber = create(:contact)
      create(:action_platform_subscription, contact: subscriber, status: :pending)

      query = Igloo::PlatformSubscriptionQuery.new
      assert_not query.include?(subscriber), "should not include inactive subscribers"
    end

    test "old subscribers are not included" do
      query = Igloo::PlatformSubscriptionQuery.new
      contact = create_subscriber(from: 1.year.ago)

      results = query.recent(1.month.ago)

      assert_not_includes_recent results, contact
    end

    test "recently updated subscribers" do
      query = Igloo::PlatformSubscriptionQuery.new
      contact = create_subscriber(from: 1.year.ago)
      contact.touch

      results = query.recent(1.month.ago)

      assert_includes_recent results, contact
    end

    test "contacts from recently updated organizations" do
      query = Igloo::PlatformSubscriptionQuery.new
      contact = create_subscriber(from: 1.year.ago)
      contact.organization.touch

      results = query.recent(1.month.ago)

      assert_includes_recent results, contact
    end

    test "contacts from recently updated sectors" do
      query = Igloo::PlatformSubscriptionQuery.new
      contact = create_subscriber(from: 1.year.ago)
      contact.organization.sector.touch

      results = query.recent(1.month.ago)

      assert_includes_recent results, contact
    end

    test "contacts from recently updated countries" do
      query = Igloo::PlatformSubscriptionQuery.new
      contact = create_subscriber(from: 1.year.ago)
      contact.country.touch

      results = query.recent(1.month.ago)

      assert_includes_recent results, contact
    end

    test "contacts with recently updated subscriptions" do
      query = Igloo::PlatformSubscriptionQuery.new
      contact = create_subscriber(from: 1.year.ago)

      subscription = ActionPlatform::Subscription.for_contact(contact)
      subscription.first.touch

      results = query.recent(1.month.ago)

      assert_includes_recent results, contact
    end

    private

    def assert_includes_recent(results, contact)
      assert_includes results.flat_map(&:contact).flat_map(&:name), contact.name
    end

    def assert_not_includes_recent(results, contact)
      assert_not_includes results.flat_map(&:contact).flat_map(&:name), contact.name
    end

    def create_subscriber(from:)
      creation_date = from
      travel_to creation_date do
        sector = create(:sector)
        country = create(:country)
        organization = create(:organization, sector: sector)
        contact = create(:contact, organization: organization, country: country)
        create(:action_platform_subscription, contact: contact)
        contact
      end
    end
  end
end
