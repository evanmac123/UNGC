require 'test_helper'

class ContributorsQueryTest < ActiveSupport::TestCase

  def create_annual_contribution(is_participant = true)
    campaign = create_campaign(name: '2014 Annual Contributions')
    participant = create_organization(participant: is_participant)
    create_contribution(
      campaign: campaign,
      organization: participant,
      raw_amount: 66_000.00,
      stage: Contribution::STAGE_POSTED
    )
  end

  def create_lead_contribution(is_participant = true)
    campaign = create_campaign(name: 'LEAD 2014 happy')
    participant = create_organization(participant: is_participant)
    create_contribution(
      campaign: campaign,
      organization: participant,
      raw_amount: 66_000.00,
      stage: Contribution::STAGE_POSTED
    )
  end

  should "return LEAD and annual contributions" do
    c1 = create_annual_contribution
    c2 = create_lead_contribution

    contributions = ContributorsQuery.contributors_for(2014)

    assert_contains contributions, c1
    assert_contains contributions, c2
  end

  should "not return contributions for non participants" do
    c1 = create_annual_contribution(false)

    contributions = ContributorsQuery.contributors_for(2014)

    refute_includes contributions, c1
  end

  should "include only POSTED contributions" do
    c1 = create_annual_contribution

    campaign = create_campaign(name: 'LEAD 2014 happy')
    participant = create_organization(participant: true)
    c2 = create_contribution(
      campaign: campaign,
      organization: participant,
      raw_amount: 66_000.00,
      stage: 'FAKE'
    )

    contributions = ContributorsQuery.contributors_for(2014)

    assert_contains contributions, c1
    refute_includes contributions, c2
  end
end
