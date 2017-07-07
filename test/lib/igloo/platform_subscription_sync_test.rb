require "test_helper"

module Igloo
  class PlatformSubscriptionPlatformSubscriptionTest < ActiveSupport::TestCase

    test "uploads recent action platform subscribers to Igloo" do
      # Given a subscriber
      create_subscriber(
        id: 1002,
        first_name: "Alice",
        last_name: "Walker",
        email: "alice@example.com",
        job_title: "Human Solutions Architect",
        sector: "Beverages",
        country: "Canada",
        organization: "Pepsi",
        platform: "Business for Inclusion",
        status: "approved")

      # And an subscriber with an expired subscription
      create_subscriber(
        id: 1004,
        first_name: "Bob",
        last_name: "Ross",
        email: "bob@example.com",
        job_title: "Direct Identity Executive",
        sector: "Health Care",
        country: "USA",
        organization: "Coke",
        platform: "Health is Everyone's Business",
        status: "approved",
        expires_on: 1.month.ago)

      last_sync = 1.week.ago

      api = mock("api")
      sync = Igloo::PlatformSubscriptionSync.new(api)

      # when we sync those contacts, the API should
      # be given properly formatted CSV for the 2 contacts
      api.expects(:bulk_upload).with() do |csv|
        # copy out the csv params so we can check it later
        @csv = CSV.parse(csv, headers: true)
        csv.present?
      end

      # Make the call
      sync.upload_recent(last_sync)

      assert_not_nil @csv, "csv argument did not parse"

      alice = @csv[0]
      assert_equal "1002", alice["customIdentifier"]
      assert_equal "Alice", alice["firstname"]
      assert_equal "Walker", alice["lastname"]
      assert_equal "alice@example.com", alice["email"]
      assert_equal "Human Solutions Architect", alice["occupation"]
      assert_equal "Beverages", alice["sector"]
      assert_equal "Canada", alice["country"]
      assert_equal "Pepsi", alice["company"]
      assert_equal "Business for Inclusion &amp; Gender Equality~Space Members", alice["groupsToAdd"]
      assert_nil alice["groupsToRemove"]

      bob = @csv[1]
      assert_equal "1004", bob["customIdentifier"]
      assert_equal "Bob", bob["firstname"]
      assert_equal "Ross", bob["lastname"]
      assert_equal "bob@example.com", bob["email"]
      assert_equal "Direct Identity Executive", bob["occupation"]
      assert_equal "Health Care", bob["sector"]
      assert_equal "USA", bob["country"]
      assert_equal "Coke", bob["company"]
      assert_nil bob["groupsToAdd"]
      assert_equal "Health is Everyone&#39;s Business~Space Members", bob["groupsToRemove"]
    end

    test "returns the number of contacts synced" do
      2.times.map do |i|
        create_subscriber(
          sector: "Health Care",
          country: "USA",
          organization: "Organization #{i}",
          platform: "Breakthrough Innovation",
          status: "approved"
        )
      end

      sync = PlatformSubscriptionSync.new(stub("api", :bulk_upload))

      count = sync.upload_recent(1.week.ago)
      assert_equal 2, count
    end

    private

    def create_subscriber(params = {})
      platform_name = params.delete(:platform)
      sector_name = params.delete(:sector)
      country_name = params.delete(:country)
      organization_name = params.delete(:organization)
      subscription_status = params.delete(:status)
      expires_on = params.delete(:expires_on)

      sector = create(:sector, name: sector_name)
      country = create(:country, name: country_name)
      organization = create(:organization, sector: sector, name: organization_name)
      contact = create(:contact, params.merge(organization: organization, country: country))
      platform = create(:action_platform_platform, name: platform_name)
      subscription = create(:action_platform_subscription,
        contact: contact,
        status: subscription_status,
        platform: platform)

      subscription.update!(expires_on: expires_on) if expires_on.present?
      contact
    end

  end
end
