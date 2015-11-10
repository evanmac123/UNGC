require 'test_helper'

class ContributorsQueryTest < ActiveSupport::TestCase

  should "return LEAD and annual contributions" do

    campaign = create_campaign(name: '2014 Annual Contributions')
    participant = create_organization(participant: true)
    c1 = create_contribution(
      campaign: campaign,
      organization: participant,
      raw_amount: 66_000.00,
      stage: Contribution::STAGE_POSTED
    )

    campaign = create_campaign(name: 'LEAD 2014 happy')
    participant = create_organization(participant: true)
    c2 = create_contribution(
      campaign: campaign,
      organization: participant,
      raw_amount: 66_000.00,
      stage: Contribution::STAGE_POSTED
    )

    contributions = ContributorsQuery.contributors_for(2014)

    assert_contains contributions, c1
    assert_contains contributions, c2
  end

  should "not return contributions for non participants" do
    campaign = create_campaign(name: '2014 Annual Contributions')
    participant = create_organization(participant: false)
    c1 = create_contribution(
      campaign: campaign,
      organization: participant,
      raw_amount: 66_000.00,
      stage: Contribution::STAGE_POSTED
    )

    contributions = ContributorsQuery.contributors_for(2014)

    refute_includes contributions, c1
  end

  should "include only POSTED contributions" do
    campaign = create_campaign(name: '2014 Annual Contributions')
    participant = create_organization(participant: true)
    c1 = create_contribution(
      campaign: campaign,
      organization: participant,
      raw_amount: 66_000.00,
      stage: Contribution::STAGE_POSTED
    )

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
