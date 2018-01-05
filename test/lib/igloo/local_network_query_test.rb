require "test_helper"

module Igloo
  class LocalNetworkQueryTest < ActiveSupport::TestCase

    test "Contacts with a login" do
      with = create_contact(username: "bob", last_name: "With")
      without = create_contact(username: nil, last_name: "Without")
      blank = create_contact(username: "", last_name: "Blank")

      query = LocalNetworkQuery.new
      results = query.recent(1.week.ago)

      assert query.include?(with), "did not allow contact with a username"
      refute query.include?(without), "allowed missing username"
      refute query.include?(blank), "allowed blank username"

      assert_includes_contact results, with
      assert_not_includes_contact results, without
      assert_not_includes_contact results, blank
    end

    test "Contacts from active local networks" do
      active = create_contact(last_name: "Network",
        network: create(:local_network,  state: :active))

      inactive  = create_contact(last_name: "Inactive",
        network: create(:local_network, state: :inactive))

      non_network = create_contact(last_name: "Non-Network",
        network: nil)

      query = LocalNetworkQuery.new
      results = query.recent(1.week.ago)

      assert query.include?(active)
      refute query.include?(inactive)
      refute query.include?(non_network)

      assert_includes_contact results, active
      assert_not_includes_contact results, inactive
      assert_not_includes_contact results, non_network
    end

    test "contains only recently updated contacts" do
      contact = travel_to(1.year.ago) { create_contact }
      query = LocalNetworkQuery.new
      assert_not_includes_contact query.recent(1.week.ago), contact

      contact.touch
      assert_includes_contact query.recent(1.week.ago), contact
    end

    test "contains contacts whose network has recently been updated" do
      contact = travel_to(1.year.ago) { create_contact }
      query = LocalNetworkQuery.new

      assert_not_includes_contact query.recent(1.week.ago), contact

      contact.local_network.touch
      assert_includes_contact query.recent(1.week.ago), contact
    end

    test "contains contacts whose country has recently been updated" do
      contact = travel_to(1.year.ago) { create_contact }
      query = LocalNetworkQuery.new

      assert_not_includes_contact query.recent(1.week.ago), contact

      contact.country.touch
      assert_includes_contact query.recent(1.week.ago), contact
    end

    private

    def create_contact(params = {})
      local_network = if params.key?(:network)
                        params.delete(:network)
                      else
                        create(:local_network, state: :active)
                      end

      create(:contact, params.reverse_merge(
        local_network: local_network,
        username: Faker::Internet.user_name,
      ))
    end

    def assert_includes_contact(contacts, contact)
      assert_includes contacts.map(&:name), contact.name
    end

    def assert_not_includes_contact(contacts, contact)
      assert_not_includes contacts.map(&:name), contact.name
    end
  end
end
