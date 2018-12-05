class PaymentGateway

  CURRENCY = "usd".freeze

  def initialize(gateway = nil)
    @gateway = gateway || Stripe::Charge
  end

  def charge(token:, amount_in_cents:, reference:, receipt_email:, metadata: {})
    @gateway.create(
      source: token,
      currency: CURRENCY,
      amount: amount_in_cents,
      idempotency_key: reference,
      receipt_email: receipt_email,
      metadata: metadata.to_h,
    )
  end

end
