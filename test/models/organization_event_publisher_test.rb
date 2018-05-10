require "test_helper"

class OrganizationEventPublisherTest < ActiveSupport::TestCase

  setup do
    travel_to Date.new(2018, 2, 3)
    TestAfterCommit.enabled = true
  end

  teardown do
    TestAfterCommit.enabled = false
    travel_back
  end

  test "no changes publish no events" do
    create(:organization)
    Organization.last.touch
  end

  test "Organization lifecycle is published" do
    params = attributes_for(:organization, name: "Nestle", employees: 23)
    o = Organization.create!(params)
    o.approve!
    o.destroy

    client = RailsEventStore::Client.new
    events = client.read_stream_events_forward(o.event_stream_name)
    created, activated, approved, destroyed = events

    assert created.is_a?(DomainEvents::OrganizationCreated)
    assert_equal created.data.dig(:changes, :name), "Nestle"
    assert_equal created.data.dig(:changes, :employees), 23
    assert_not_empty created.data.fetch(:caller)

    assert activated.is_a?(DomainEvents::OrganizationUpdated)
    expected = {
      "active" => true,
      "cop_due_on" => 1.year.from_now
    }
    assert_equal expected, activated.data.fetch(:changes)
    assert_not_empty activated.data.fetch(:caller)

    assert approved.is_a?(DomainEvents::OrganizationUpdated)
    expected = {
      "participant" => true,
      "state" => "approved",
      "joined_on" => Date.current
    }
    assert_equal expected, approved.data.fetch(:changes)
    assert_not_empty approved.data.fetch(:caller)

    assert destroyed.is_a?(DomainEvents::OrganizationDestroyed)
    assert_equal o.id, destroyed.data.fetch("id")
    assert_not_empty destroyed.data.fetch("caller")
  end
end
