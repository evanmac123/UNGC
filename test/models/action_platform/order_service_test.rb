require "test_helper"

module ActionPlatform
  class OrderServiceTest < ActiveSupport::TestCase

    test "it creates an order" do
      # Given an Organization with a financial contact
      organization = create(:organization)
      contact = create_financial_contact(organization)

      # And 2 Platforms
      p1 = create(:action_platform_platform)
      p2 = create(:action_platform_platform, default_starts_at: 1.year.from_now, default_ends_at: 2.years.from_now)

      # When we use the service to create an order
      crm = mock("crm")
      crm.expects(:create)
        .with('ActionPlatformOrder__c', anything)
        .twice

      service = OrderService.new(organization, contact, crm: crm)
      service.subscribe(contact_id: contact.id, platform_id: p1.id)
      service.subscribe(contact_id: contact.id, platform_id: p2.id)


      order = service.create_order
      subscription1, subscription2 = order.subscriptions

      assert_not_nil order
      assert_equal organization, order.organization
      assert_equal contact, order.financial_contact

      assert_not_nil subscription1
      assert_equal contact, subscription1.contact
      assert_equal p1, subscription1.platform
      assert_equal p1.default_starts_at, subscription1.starts_on
      assert_equal p1.default_ends_at, subscription1.expires_on

      assert_not_nil subscription2
      assert_equal contact, subscription2.contact
      assert_equal p2, subscription2.platform
      assert_equal p2.default_starts_at, subscription2.starts_on
      assert_equal p2.default_ends_at, subscription2.expires_on

      assert_equal "pending", order.status

      assert_not_nil event = event_store.read_all_streams_forward.first
      assert event.is_a?(DomainEvents::ActionPlatformOrderCreated)
    end

    private

    def create_financial_contact(organization)
      create(:contact, :financial_contact, organization: organization)
    end

    # it publishes an event
    # it sends the order and subscription to salesforce

    # when it fails
    # it does not publish an event
    # it does not send data to salesforce
    # it does not create an order
    # it does not create an subscriptions

    # Move to form:
    # it updates organization with new revenue
    # it updates contact info
  end
end
