require "test_helper"

module Igloo
  class LocalNetworkSyncTest < ActiveSupport::TestCase

    test "customIdentifier" do
      contact = build_network_contact(id: 123)
      sync = LocalNetworkSync.new(nil)
      assert_equal "123", sync.convert(contact).fetch("customIdentifier")
    end

    test "firstname" do
      contact = build_network_contact(first_name: "Alice", middle_name: "Malsenior")
      sync = LocalNetworkSync.new(nil)
      assert_equal "Alice Malsenior", sync.convert(contact).fetch("firstname")
    end

    test "lastname" do
      contact = build_network_contact(last_name: "Walker")
      sync = LocalNetworkSync.new(nil)
      assert_equal "Walker", sync.convert(contact).fetch("lastname")
    end

    test "email" do
      contact = build_network_contact(email: "alice@example.com")
      sync = LocalNetworkSync.new(nil)
      assert_equal "alice@example.com", sync.convert(contact).fetch("email")
    end

    test "occupation" do
      contact = build_network_contact(roles: [
        Role.contact_point,
        Role.network_focal_point
      ])

      sync = LocalNetworkSync.new(nil)
      assert_equal "Contact Point, Network Contact Person", sync.convert(contact).fetch("occupation")
    end

    test "country" do
      contact = build_network_contact(country: build(:country, name: "France"))
      sync = LocalNetworkSync.new(nil)
      assert_equal "France", sync.convert(contact).fetch("country")
    end

    test "nordic country" do
      network = build(:local_network, name: "Nordic Country")
      contact = build_network_contact(local_network: network, country: build(:country, name:"Iceland"))
      sync = LocalNetworkSync.new(nil)
      assert_equal "Iceland", sync.convert(contact).fetch("country")
    end

    test "city" do
      contact = build_network_contact(city: "London")
      sync = LocalNetworkSync.new(nil)
      assert_equal "London", sync.convert(contact).fetch("city")
    end

    test "state" do
      contact = build_network_contact(state: "Ontario")
      sync = LocalNetworkSync.new(nil)
      assert_equal "Ontario", sync.convert(contact).fetch("state")
    end

    test "zipcode" do
      contact = build_network_contact(postal_code: "90210")
      sync = LocalNetworkSync.new(nil)
      assert_equal "90210", sync.convert(contact).fetch("zipcode")
    end

    test "phone" do
      contact = build_network_contact(phone: "1-234-456-7890")
      sync = LocalNetworkSync.new(nil)
      assert_equal "1-234-456-7890", sync.convert(contact).fetch("phone")
    end

    test "company" do
      network = build(:local_network, name: "France")
      contact = build_network_contact(local_network: network)
      sync = LocalNetworkSync.new(nil)
      assert_equal "LN France", sync.convert(contact).fetch("company")
    end

    test "groupsToAdd" do
      contact = build_network_contact
      sync = LocalNetworkSync.new(nil)
      assert_equal "Local Network Members", sync.convert(contact).fetch("groupsToAdd")
    end

    test "sends multiple contacts to the API" do
      api = mock("api")
      sync = LocalNetworkSync.new(api)
      cutoff = 1.week.ago

      create_network_contact(first_name: "Alice")
      create_network_contact(first_name: "Bob")

      api.expects(:bulk_upload).with() do |csv|
        @csv = CSV.parse(csv, headers: true)
      end

      sync.upload_recent(cutoff)

      alice = @csv[0]
      assert_not_nil alice
      assert_equal "Alice", alice["firstname"]

      bob = @csv[1]
      assert_not_nil bob
      assert_equal "Bob", bob["firstname"]
    end

    test "returns the number of contacts synced" do
      2.times.map { create_network_contact }

      sync = LocalNetworkSync.new(stub("api", :bulk_upload))

      count = sync.upload_recent(1.week.ago)
      assert_equal 2, count
    end

    private

    def build_network_contact(params = {})
      build(:contact, params.reverse_merge(
        local_network: build(:local_network, state: "Active")
      ))
    end

    def create_network_contact(params = {})
      build_network_contact(params).tap { |c| c.save! }
    end

  end
end
