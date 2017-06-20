class PaymentGateway

  CURRENCY = "usd".freeze

  def initialize(gateway = nil)
    @gateway = gateway || Stripe::Charge
  end

  def charge(token:, amount_in_cents:, reference:, metadata: {})
    @gateway.create(
      source: token,
      currency: CURRENCY,
      amount: amount_in_cents,
      idempotency_key: reference,
      metadata: metadata.to_h
    )
  end

end
