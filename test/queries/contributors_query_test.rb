require 'test_helper'

class ContributorsQueryTest < ActiveSupport::TestCase

  def create_annual_contribution(is_participant = true)
    campaign = create(:campaign, name: '2014 Annual Contributions')
    participant = create(:organization, participant: is_participant)
    create(:contribution,
      campaign: campaign,
      organization: participant,
      raw_amount: 66_000.00,
      stage: Contribution::STAGE_POSTED
    )
  end

  def create_lead_contribution(is_participant = true)
    campaign = create(:campaign, name: 'LEAD 2014 happy')
    participant = create(:organization, participant: is_participant)
    create(:contribution,
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

    campaign = create(:campaign, name: 'LEAD 2014 happy')
    participant = create(:organization, participant: true)
    c2 = create(:contribution,
      campaign: campaign,
      organization: participant,
      raw_amount: 66_000.00,
      stage: 'FAKE'
    )

    contributions = ContributorsQuery.contributors_for(2014)

    assert_contains contributions, c1
    refute_includes contributions, c2
  end

  should "include only contributions from organizations that match the query" do
    campaign = create(:campaign, name: 'LEAD 2014 happy')
    participant = create(:organization, name: 'my org', participant: true)
    c1 = create(:contribution,
      campaign: campaign,
      organization: participant,
      raw_amount: 66_000.00,
      stage: 'posted'
    )
    participant2 = create(:organization, name: 'my not org', participant: true)
    c2 = create(:contribution,
      campaign: campaign,
      organization: participant2,
      raw_amount: 66_000.00,
      stage: 'posted'
    )

    contributions = ContributorsQuery.search('my org')

    assert_contains contributions, c1
    refute_includes contributions, c2
  end

  should "not return results for short queries" do
    campaign = create(:campaign, name: 'LEAD 2014 happy')
    participant = create(:organization, name: 'my org', participant: true)
    create(:contribution,
      campaign: campaign,
      organization: participant,
      raw_amount: 66_000.00,
      stage: 'posted'
    )
    assert ContributorsQuery.search('my').empty?
    assert ContributorsQuery.search(' my').empty?
    assert ContributorsQuery.search('    s ').empty?
  end

  should "should ignore accents" do
    campaign = create(:campaign, name: 'LEAD 2014 happy')
    participant = create(:organization, name: 'Fundación Bancaria "la Caixa"', participant: true)
    c1 = create(:contribution,
      campaign: campaign,
      organization: participant,
      raw_amount: 66_000.00,
      stage: 'posted'
    )
    contributions = ContributorsQuery.search('fundacion')

    assert_contains contributions, c1
  end
end
