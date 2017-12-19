require "test_helper"

module ActionPlatform
  class OrderTest < ActiveSupport::TestCase

    test "deleting an organization is prevented if action platform orders exist" do
      # Given an order with a subscription that belong to an organization
      organization = create(:organization)
      contact = create(:contact_point, organization: organization)

      order_service = OrderService.new(organization, contact,
                                       crm: false, mailer: false)

      platform = create(:action_platform_platform)
      order_service.subscribe(platform_id: platform.id,
                              contact_id: contact.id)

      order_service.create_order

      assert_not organization.destroy, 'Organization was destroyed'

      assert_equal organization.errors[:base], ['Cannot delete record because dependent action platform orders exist']
    end
  end
end
