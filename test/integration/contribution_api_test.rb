require 'test_helper'

class ContributionApiTest < ActionDispatch::IntegrationTest

  should "show contribution data for the given year" do
    # given a participant who contributes to a campaign in the year
    campaign = create_campaign(name: '2014 Annual Contributions')
    participant = create_organization
    contribution = create_contribution(
      campaign: campaign,
      organization: participant,
      raw_amount: 66_000.00,
      stage: Contribution::STAGE_POSTED
    )

    # when i visit the end point
    visit '/api/v1/contributors/2014'
    assert_equal 200, page.status_code

    # then I see it in the json output
    expected = [
      {
        "id" => participant.id,
        "type" => 'annual',
        "name" => participant.name,
        "url" => participant_url(participant),
        "amount" => "$USD > 15,000"
      }
    ]

    json_body = JSON.parse(page.body)
    assert_equal expected, json_body
  end

  should "show contribution data for lead campaigns" do
    # given a participant who contributes to a lead campaign in the year
    campaign = create_campaign(name: 'LEAD 2014 happy')
    participant = create_organization
    contribution = create_contribution(
      campaign: campaign,
      organization: participant,
      raw_amount: 66_000.00,
      stage: Contribution::STAGE_POSTED
    )

    # when i visit the end point
    visit '/api/v1/contributors/2014'
    assert_equal 200, page.status_code

    # then I see it in the json output
    expected = [
      {
        "id" => participant.id,
        "type" => 'lead',
        "name" => participant.name,
        "url" => participant_url(participant),
        "amount" => "$USD 65,000"
      }
    ]

    json_body = JSON.parse(page.body)
    assert_equal expected, json_body
  end

end
