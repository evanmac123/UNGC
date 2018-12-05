require "test_helper"

class PaymentGatewayTest < ActiveSupport::TestCase

  test "it passes the right values to the underlying gateway" do

    gateway = PaymentGateway.new

    request = {
      source: "token",
      amount: "12345",
      currency: "usd",
      receipt_email: "alice@example.com",
      idempotency_key: "reference",
      metadata: {
        custom: "true"
      },
    }

    response = {
      id: "charge-id",
      status: "succeeded"
    }

    stub_request(:post, "https://api.stripe.com/v1/charges")
      .with(body: request, headers: { "Authorization" => "Bearer #{api_key}" })
      .to_return(body: response.to_json)

    charge = gateway.charge(
      token: "token",
      amount_in_cents: 12345,
      receipt_email: "alice@example.com",
      reference: "reference",
      metadata: { custom: true }
    )

    assert_equal "charge-id", charge.id
    assert_equal "succeeded", charge.status
  end

  private

  def api_key
    Stripe.api_key
  end

end
