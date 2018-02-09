class Donation::ChargeDonor
  attr_reader :donation, :log

  def self.charge(donation)
    self.new(donation).charge
  end

  def initialize(donation, payment_gateway: nil, log: nil)
    @donation = donation
    @payment_gateway = payment_gateway || PaymentGateway.new
    @log = log || NotificationServiceLogger.new
  end

  def charge
    donation.valid? && process_payment
  end

  private

  def process_payment
    donation.save!
    charge = create_stripe_charge
    handle_success(donation, charge)
    enqueue_crm_sync(donation)
    true
  rescue Stripe::CardError => e
    handle_card_error(donation, e)
    false
  rescue Stripe::StripeError => e
    handle_stripe_error(donation, e)
    false
  end

  def handle_success(donation, charge)
    donation.update!(
      status: charge.status,
      response_id: charge.id,
      full_response: charge.to_json
    )
    EventPublisher.publish(create_success_event, to: stream_name(donation))
  end

  def handle_card_error(donation, e)
    donation.update!(
      status: "failed",
      full_response: e.json_body || {}.to_json
    )
    EventPublisher.publish(create_failure_event, to: stream_name(donation))
  end

  def handle_stripe_error(donation, e)
    donation.update!(
      status: "failed",
      full_response: e.json_body || {}.to_json
    )
    EventPublisher.publish(create_failure_event, to: stream_name(donation))
    @log.error("Failed to accept donation", e, donation.attributes)
  end

  def enqueue_crm_sync(donation_form)
    donation = ::Donation.find(donation_form.id)
    Crm::DonationSyncJob.perform_later('create', donation, {})
  end

  def create_stripe_charge
    @payment_gateway.charge(
      token: donation.token,
      amount_in_cents: donation.amount.cents,
      reference: donation.reference,
      metadata: donation.metadata
    )
  end

  def publish_event(success)
    event = create_event(success)
    EventPublisher.publish(event, to: stream_name(donation))
  end

  def create_event(success)
    if success
      create_success_event
    else
      create_failure_event
    end
  end

  def create_success_event
    Donation::CreatedEvent.new(data: {
      donation_id: donation.id,
      reference: donation.reference,
      amount: donation.amount.cents,
      organization_id: donation.organization_id,
      contact_id: donation.contact_id
    })
  end

  def create_failure_event
    Donation::FailedEvent.new(data: {
      reference: donation.reference,
      amount: donation.amount.cents,
      organization_id: donation.organization_id,
      contact_id: donation.contact_id
    })
  end

  def stream_name(donation)
    "donation_#{donation.id}"
  end

end
