require 'test_helper'

class ContributionStatusPresenterTest < ActionController::TestCase
  setup do
    # We don't want to hard code years since these rules are year independent
    create_approved_organization_and_user
    @campaign_past_year = create_campaign(name: "#{Date.today.year - 2} Annual Contributions")
    @campaign_last_year = create_campaign(name: "#{Date.today.year - 1} Annual Contributions")
    @campaign_this_year = create_campaign(name: "#{Date.today.year} Annual Contributions")
    @campaign_next_year = create_campaign(name: "#{Date.today.year + 1} Annual Contributions")
    @organization.contributions << create_contribution(raw_amount: 5000, stage: 'Posted', campaign_id: @campaign_past_year.id)
    @organization.contributions << create_contribution(raw_amount: 2500, stage: 'Posted', campaign_id: @campaign_last_year.id)
    @organization.update_attribute :joined_on, '2012-01-01'
    cs = ContributionStatusQuery.for_organization(@organization)
    @p = ContributionStatusPresenter.new(cs)
  end


  should "return the contribution years" do
    assert_equal(@p.contribution_years, [
      {year: 2015, contributed: false},
      {year: 2014, contributed: true},
      {year: 2013, contributed: true},
      {year: 2012, contributed: false}
    ])
  end
end

