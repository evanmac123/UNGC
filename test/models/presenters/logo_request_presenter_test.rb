require 'test_helper'

class LogoRequestPresenterTest < ActionController::TestCase
  setup do
    # We don't want to hard code years since these rules are year independent
    create_approved_organization_and_user
    @campaign_past_year = create(:campaign, name: "#{Date.current.year - 2} Annual Contributions")
    @campaign_last_year = create(:campaign, name: "#{Date.current.year - 1} Annual Contributions")
    @campaign_this_year = create(:campaign, name: "#{Date.current.year} Annual Contributions")
    @campaign_next_year = create(:campaign, name: "#{Date.current.year + 1} Annual Contributions")
    @organization.contributions << create(:contribution, raw_amount: 5000, stage: 'Posted', campaign_id: @campaign_past_year.id)
    @organization.update_attribute :joined_on, '2012-01-01'
    cs = ContributionStatusQuery.for_organization(@organization)
    @l = LogoRequestPresenter.new(Object.new, cs)
  end


  should "should know if the logo_request has a missing contribution" do
    assert @l.missing_contribution?
  end

  should "should know if the logo_request doesn't have a missing contribution" do
    @organization.contributions << create(:contribution, raw_amount: 5000, stage: 'Posted', campaign_id: @campaign_last_year.id)
    refute @l.missing_contribution?
  end

  should "print the proper contribution_status_message" do
    assert_equal @l.contribution_status_message, "No contribution received for #{Date.current.year} - #{Date.current.year - 1}"
  end
end
