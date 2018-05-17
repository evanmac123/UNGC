require "test_helper"

class Organization::InvoicingPolicyTest < ActiveSupport::TestCase

  test "When no revenue sharing info is available, invoicing is required" do
    policy = create_policy(model: nil)
    assert policy.invoicing_required?
  end

  test "When revenue sharing is managed by GCO, invoicing is required" do
    policy = create_policy(
      model: "revenue_sharing",
      managed_by: "gco",
    )

    assert policy.invoicing_required?
  end

  test "When revenue sharing is managed by the network, invoicing is up to the network" do
    policy = create_policy(
      model: "revenue_sharing",
      managed_by: "local_network",
      required: "yes",
    )

    assert policy.invoicing_required?

    policy = create_policy(
      model: "revenue_sharing",
      managed_by: "local_network",
      required: "no",
    )

    assert_not policy.invoicing_required?
  end

  test "When using the Global Local model and company revenue is $1bn or over, invoicing is required" do
    policy = create_policy(
      model: "global_local",
      revenue: Money.from_amount(1_000_000_000.00),
     )

    assert policy.invoicing_required?
  end

  test "When using the Global Local model and company revenue is under a billion, invoicing is up to the network" do
    under = Money.from_amount(999_999_999.99)
    policy = create_policy(
      model: "global_local",
      revenue: under,
      required: "yes"
    )

    assert policy.invoicing_required?

    policy = create_policy(
      model: "global_local",
      revenue: under,
      required: "no"
    )

    assert_not policy.invoicing_required?
  end

  test "When the network has not yet selected a business model, then invoicing options are not shown" do
    policy = create_policy(
      model: "not_yet_decided",
      required: "yes",
    )
    refute policy.invoicing_required?

    policy = create_policy(
      model: "not_yet_decided",
      required: "no",
    )
    refute policy.invoicing_required?
  end

  test "when no revenue is available" do
    policy = create_policy(model: "global_local", revenue: nil)
    refute policy.invoicing_required?
  end

  test "dates in the past are not valid" do
    travel_to Date.new(2017, 1, 2) do
      policy = create_policy(invoice_date: 1.day.ago)

      policy.validate(policy.organization)
      assert_includes policy.organization.errors.full_messages,
        "Invoice date can't be in the past"
    end
  end

  test "dates more than a year out are not valid" do
    travel_to Date.new(2017, 1, 2) do
      more_than_a_year_from_now = Date.current + 1.year + 1.day
      policy = create_policy(invoice_date: more_than_a_year_from_now)

      policy.validate(policy.organization)
      assert_includes policy.organization.errors.full_messages,
        "Invoice date can't be more than a year from now"
    end
  end

  test "valid dates are allowed" do
    travel_to Date.new(2017, 1, 2) do
      policy = create_policy(invoice_date: Date.new(2017, 1, 2))

      policy.validate(policy.organization)
      assert_empty policy.organization.errors.full_messages
    end
  end

  test "valid incorrect invoice_date type" do
    form = Organization::LevelOfParticipationForm.new(invoice_date: "no invoice")
    assert_includes_error form, "Invoice date must be a valid date"
  end

  test "default invoicing strategy" do
    strategy = Organization::InvoicingPolicy::DefaultStrategy.new

    expected = {type: :default, value: true}
    assert_equal expected, strategy.to_h
  end

  test "revenue sharing invoicing strategy" do
    network = build(:local_network,
      business_model: :revenue_sharing,
      invoice_managed_by: :gco)
    strategy = Organization::InvoicingPolicy::RevenueSharing.new(network)

    expected = {type: "revenue_sharing", value: true}
    assert_equal expected, strategy.to_h
  end

  test "global-local invoicing strategy" do
    network = build(:local_network,
      business_model: :global_local,
      invoice_options_available: :no)
    strategy = Organization::InvoicingPolicy::GlobalLocal.new(network, nil)

    expected = {
      type: "global_local",
      threshold_in_dollars: 1_000_000_000,
      local: false,
      global: true
    }

    assert_equal expected, strategy.to_h
  end

  test "not yet decided invoicing strategy" do
    network = build(:local_network, business_model: :not_yet_decided)
    strategy = Organization::InvoicingPolicy::NotYetDecided.new(network)

    expected = {type: "not_yet_decided", value: false}
    assert_equal expected, strategy.to_h
  end

  context "When the date is before Nov 30 2018" do

    setup     { travel_to(Date.new(2018, 11, 1)) }
    teardown  { travel_back }

    should "'Invoice me now' and 'Invoice me on:' are both available" do
      now, on = create_policy.options.map(&:first)
      assert_equal "Invoice me now", now
      assert_equal "Invoice me on:", on
    end

    should "Today is a valid invoice date" do
      policy = create_policy(invoice_date: Date.current)
      organization = policy.organization

      assert policy.validate(organization), organization.errors.full_messages
    end

    should "Dates between today and Nov 30 are not valid" do
      policy = create_policy(invoice_date: 1.day.from_now.to_date)
      organization = policy.organization

      policy.validate(organization)

      assert_includes organization.errors.full_messages,
        "Invoice date must be after 2018-11-30"
    end

    should "Nov 30 is a valid invoice date" do
      policy = create_policy(invoice_date: Date.new(2018, 11, 30))
      organization = policy.organization

      assert policy.validate(organization), organization.errors.full_messages
    end

    should "Invoice dates within 1 year are valid" do
      policy = create_policy(invoice_date: 1.year.from_now)
      organization = policy.organization

      assert policy.validate(organization), organization.errors.full_messages
    end

  end

  should "Invoice me now is the only option after Nov 30 2018" do
    travel_to Date.new(2018, 11, 30) do
      policy = create_policy
      options = policy.options.map(&:first)
      assert_equal ["Invoice me now"], options
    end
  end

  private

  def create_policy(model: nil, managed_by: nil, required: nil, revenue: nil,
                    invoice_date: nil)
    network = create(:local_network,
      business_model: model,
      invoice_managed_by: managed_by,
      invoice_options_available: required)

    organization = create(:organization,
      precise_revenue: revenue,
      invoice_date: invoice_date,
      country: create(:country, local_network: network))

    Organization::InvoicingPolicy.new(organization, revenue)
  end

end
