require "test_helper"

module ActionPlatform
  class OrderTest < ActiveSupport::TestCase

    test "deleting an organization cleans up orders and subscriptions" do
      # Given an order with a subscription that belong to an organization
      organization = create(:organization)
      contact = create(:contact)

      order_service = OrderService.new(organization, contact,
                                       crm: false, mailer: false)

      platform = create(:action_platform_platform)
      order_service.subscribe(platform_id: platform.id,
                              contact_id: contact.id)

      order_service.create_order

      # When the organization is destroyed
      # Then the order and it's subscriptions are destroyed also
      assert_difference -> { Order.count }, -1 do
        assert_difference -> { Subscription.count }, -1 do
          organization.destroy
        end
      end
    end

  end
end
