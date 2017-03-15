require "test_helper"

module ActionPlatform
  class OrderFormTest < ActiveSupport::TestCase

    setup do
      create_list(:action_platform_platform, 3)
    end

    test "the form is valid with valid inputs" do
      form = OrderForm.new(validate_attributes)
      assert form.valid?, -> {
        form.errors.full_messages
      }
    end

    test "creates an order with valid inputs" do
      form = OrderForm.new(validate_attributes)
      form.order_service = mock("order_service")

      expected_args = has_entries(
        organization_id: organization.id,
        contact_id: financial_contact.id,
        contact_attributes: has_entries(
          email: financial_contact.email
        ),
        revenue: "$3,200,000"
      )

      order_service = mock("order_service")
      form.order_service.expects(:new)
        .with(organization, financial_contact)
        .returns(order_service)

      order_service.expects(:subscribe).times(3)

      order_service.expects(:create_order)
        .returns(stub(id: 123))

      assert form.create
      assert_equal 123, form.id
    end

    private

    def validate_attributes
      platforms = Platform.all

      subscriptions = platforms.each_with_object({}) do |platform, subs|
        subs[platform.id] = {
          platform_id: platform.id,
          contact_id: build_stubbed(:contact).id,
          selected: "1"
        }
      end
      {
        accepts_terms_of_use: "1",
        confirm_financial_contact: "1",
        revenue: "$3,200,000",
        financial_contact_id: financial_contact.id,
        organization: organization,
        subscriptions: subscriptions,
      }.merge(financial_contact.attributes)
    end

    def organization
      @_organization ||= create(:organization)
    end

    def financial_contact
      @_financial_contact ||= create(:contact,
                                     organization: organization,
                                     state: "California",
                                     postal_code: "90210")
    end
  end
end
