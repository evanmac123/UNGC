require "test_helper"
require "sidekiq/testing"

class Donation::ChargeDonorTest < ActiveSupport::TestCase

  setup do
    Sidekiq::Testing.inline!
    ::Restforce.stubs(:new).returns(FakeRestforce.new)
  end

  test "a successful donation" do
    # Given a donation form has been filled out
    donation = build(:donation_form)

    # And the payment is submitted to the payment gateway
    gateway = mock_gateway_with_charge(id: "abc123", status: "succeeded")

    # When the charge is submitted
    donor_charge = Donation::ChargeDonor.new(donation, payment_gateway: gateway)

    # Then it is successful
    assert donor_charge.charge

    # And the donation is written to the database
    assert donation.persisted?

    # And the status is updated based on the gateway's response
    assert donation.succeeded?

    # And the donation has a reference to the charge
    assert_equal "abc123", donation.response_id

    # And the full_response is capture for future use
    json_response = JSON.parse(donation.full_response)
    expected_response = { "id" => "abc123", "status" => "succeeded" }
    assert_equal expected_response, json_response

    # And an event is published
    event = events.last
    assert_not_nil event
    assert event.is_a?(::Donation::CreatedEvent)

    # And a job to sync with the CRM is enqueued
    assert 1, ::Crm::DonationSyncWorker.jobs.size
  end

  test "no charge is made for an invalid donation" do
    # Given a donation with a missing token
    donation = build(:donation_form, token: nil)

    service = Donation::ChargeDonor.new(donation)

    # the charge fails
    refute service.charge

    # the donation is not saved
    refute donation.persisted?

    # and no events are recorded
    assert events.empty?
  end

  test "a card failure" do
    # Given a valid donation form
    donation = build(:donation_form)

    # With a card error
    gateway = mock_gateway_with_error(donation, card_error)

    # When the charge is made
    log = mock("log")
    log.expects(:error).never
    donor_charge = Donation::ChargeDonor.new(donation,
                                             payment_gateway: gateway, log: log)

    # Then it will fail
    refute donor_charge.charge

    # The donation is saved
    assert donation.persisted?

    # And marked as failed
    assert donation.failed?

    # The full response is captured
    json_response = JSON.parse(donation.full_response)
    expected_response = {"error" => {"code" => "invalid_expiry_year"}}
    assert_equal expected_response, json_response

    # Events are produced
    assert_not_nil event = events.last
    assert event.is_a? ::Donation::FailedEvent
  end

  test "a Stripe failure" do
    # Given a valid donation form
    donation = build(:donation_form)

    # With an invalid expiration year
    error = stripe_error
    gateway = mock_gateway_with_error(donation, error)

    # When the charge is made
    log = mock("log")
    log.expects(:error)
      .with("Failed to accept donation", error,
        has_entry("reference" => donation.reference))
    donor_charge = Donation::ChargeDonor.new(donation,
                                             payment_gateway: gateway, log: log)

    # Then it will fail
    refute donor_charge.charge

    # The donation is saved
    assert donation.persisted?

    # And marked as failed
    assert donation.failed?

    # The full response is captured
    json_response = JSON.parse(donation.full_response)
    assert_equal({}, json_response)

    # Events are produced
    assert_not_nil event = events.last
    assert event.is_a? ::Donation::FailedEvent
  end

  private

  def mock_gateway_with_charge(charge_params)
    charge = Stripe::Charge.construct_from(charge_params)
    stripe = mock("payment_gateway", create: charge)
    PaymentGateway.new(stripe)
  end

  def mock_gateway_with_error(donation, error)
    stripe = mock("payment_gateway")
    stripe.expects(:create).raises(error)
    PaymentGateway.new(stripe)
  end

  def card_error
    Stripe::CardError.new(
      "Your card's expiration year is invalid", "exp_year",
      "invalid_expiry_year", 402, nil, {
        error: { code: "invalid_expiry_year" }
      }.to_json
    )
  end

  def stripe_error
    Stripe::APIConnectionError.new("Could not connect to Stripe.")
  end

  def events
    event_store.read_all_streams_forward
  end

  def event_store
    @_client ||= RailsEventStore::Client.new
  end

end
