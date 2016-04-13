require 'test_helper'

class ContributionStatusPresenterTest < ActionController::TestCase

  should "return the contribution years" do
    @this_year = Date.today.year
    @next_year = @this_year + 1
    @last_year = @this_year - 1
    @two_years_ago = @this_year - 2

    # Given an organization that joined 2 years ago
    create_approved_organization_and_user
    @organization.update_attribute :joined_on, DateTime.new(@this_year - 2, 1, 1)

    # and that there are annual contribution campaigns going back that long
    old_campaign = create(:campaign, name: "#{@two_years_ago} Annual Contributions")
    last_year_campaign = create(:campaign, name: "#{@last_year} Annual Contributions")
    create(:campaign, name: "#{@this_year} Annual Contributions")
    create(:campaign, name: "#{@next_year} Annual Contributions")

    # and the organization has contributted for to the first two years
    @organization.contributions << create(:contribution, raw_amount: 5000, stage: 'Posted', campaign: old_campaign)
    @organization.contributions << create(:contribution, raw_amount: 2500, stage: 'Posted', campaign: last_year_campaign)

    # when I query for their contribution status
    status = ContributionStatusQuery.for_organization(@organization)
    @status = ContributionStatusPresenter.new(status)

    # i should see their contributions for the last 2 years
    expected = [
      {year: @this_year, contributed: false},
      {year: @last_year, contributed: true},
      {year: @two_years_ago, contributed: true},
    ]

    assert_equal(expected, @status.contribution_years)
  end

end
