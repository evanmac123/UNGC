require 'test_helper'

class ContributionApiTest < ActionDispatch::IntegrationTest

  should "show us json" do
    # given a participant who contributes to a campaign
    campaign = create_campaign(name: '2014 Annual Contributions')
    participant = create_organization # TODO participant
    contribution = create_contribution(
      campaign: campaign,
      organization: participant,
      raw_amount: 66_000.00,
      stage: Contribution::STAGE_POSTED
    )

    # when i visit the end point
    visit '/api/v1/contributors/2014'
    assert_equal 200, page.status_code

    # we expect to see it in the json output
    expected = [
      {
        "id" => participant.id,
        "type" => nil,
        "name" => participant.name,
        "url" => participant_url(participant),
        "amount" => "$USD > 15,000"
      }
    ]

    json_body = JSON.parse(page.body)
    assert_equal expected, json_body
  end

end
