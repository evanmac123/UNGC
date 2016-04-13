require 'test_helper'

class LogoRequestsPresenterTest < ActionController::TestCase
  setup do
    # We don't want to hard code years since these rules are year independent
    lr1 = create_new_logo_request
    create_organization_and_user
    lr2 = create(:logo_request, contact_id: @organization_user.id,
                                        organization_id: @organization.id)
    @campaign_past_year = create(:campaign, name: "#{Date.today.year - 2} Annual Contributions")
    @campaign_last_year = create(:campaign, name: "#{Date.today.year - 1} Annual Contributions")
    @campaign_this_year = create(:campaign, name: "#{Date.today.year} Annual Contributions")
    @campaign_next_year = create(:campaign, name: "#{Date.today.year + 1} Annual Contributions")
    lr1.organization.contributions << create(:contribution, raw_amount: 5000, stage: 'Posted', campaign_id: @campaign_past_year.id)
    lr1.organization.update_attribute :joined_on, '2012-01-01'
    cs = ContributionStatusQuery.for_organizations([lr1.organization, lr2.organization])
    @l = LogoRequestsPresenter.new([lr1, lr2], cs)
  end


  should "returns a LogoRequestPresenter for each logoRequest" do
    @l.each do |p|
      assert_equal p.class, LogoRequestPresenter
      assert p.missing_contribution?
    end
  end
end
