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

  test "When the network has not yet selected a business model, then invoicing is up to the network" do
    policy = create_policy(
      model: "not_yet_decided",
      required: "yes",
    )
    assert policy.invoicing_required?

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
      more_than_a_year_from_now = Time.zone.now.to_date + 1.year + 1.day
      policy = create_policy(invoice_date: more_than_a_year_from_now)

      policy.validate(policy.organization)
      assert_includes policy.organization.errors.full_messages,
        "Invoice date can't be more than a year from now"
    end
  end

  test "valid dates are allowed" do
    travel_to Date.new(2017, 1, 2) do
      policy = create_policy(invoice_date: Date.new(2018, 1, 1))

      policy.validate(policy.organization)
      assert_empty policy.organization.errors.full_messages
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
