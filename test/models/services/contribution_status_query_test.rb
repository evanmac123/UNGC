require 'test_helper'

class ContributionStatusQueryTest < ActionController::TestCase

  setup do
    # We don't want to hard code years since these rules are year independent
    create_approved_organization_and_user
    @campaign_past_year = create_campaign(name: "#{Date.today.year - 2} Annual Contributions")
    @campaign_last_year = create_campaign(name: "#{Date.today.year - 1} Annual Contributions")
    @campaign_this_year = create_campaign(name: "#{Date.today.year} Annual Contributions")
    @campaign_next_year = create_campaign(name: "#{Date.today.year + 1} Annual Contributions")
    @cs = ContributionStatusQuery.for_organization(@organization)
  end


  # Permission to submit Logo Requests

  context "An organization that has made contributions two years ago" do
    setup do
      @organization.contributions << create_contribution(raw_amount: 5000, stage: 'Posted', campaign_id: @campaign_past_year.id)
      @organization.contributions << create_contribution(raw_amount: 2500, stage: 'Posted', campaign_id: @campaign_past_year.id)
    end

    should "not be allowed to submit a Logo Request" do
      refute @cs.can_submit_logo_request?
    end
  end

  context "An organization that has withdrawn a contribution for the current year" do
    setup do
      @organization.contributions << create_contribution(raw_amount: 5000, stage: 'Posted', campaign_id: @campaign_past_year.id)
      @organization.contributions << create_contribution(raw_amount: 5000, stage: 'Withdrawn', campaign_id: @campaign_this_year.id)
    end

    should "not be not allowed to submit a Logo Request" do
      refute @cs.can_submit_logo_request?
    end
  end

  context "An organization that has made a contribution for the following year" do
    setup do
      @organization.contributions << create_contribution(raw_amount: 5000, stage: 'Posted', campaign_id: @campaign_past_year.id)
      @organization.contributions << create_contribution(raw_amount: 5000, stage: 'Posted', campaign_id: @campaign_next_year.id)
    end

    should "be allowed to submit a Logo Request" do
      assert @cs.can_submit_logo_request?, "should be allowed to submit a logo request"
    end
  end


  # Valid initial and final contribution years

  context "An organization that joined in 2004" do
    setup do
      @organization.update_attribute :joined_on, '2004-01-01'
    end

    should "have 2006 for their initial_contribution_year" do
      assert_equal @cs.initial_contribution_year, 2006
    end
  end


  context "An organization that joined in 2012" do
    setup do
      @organization.update_attribute :joined_on, '2012-01-01'
    end

    should "have 2012 for their initial_contribution_year" do
      assert_equal @cs.initial_contribution_year, 2012
    end

    should "have a contribution years from 2012 to present year" do
      valid_years = Array(2012..Date.today.year)
      assert_same_elements valid_years, @cs.contribution_years_range
    end

    context "and is delisted in 2013" do
      setup do
        @organization.update_attribute :delisted_on, '2013-01-01'
        @organization.update_attribute :cop_state, Organization::COP_STATE_DELISTED
      end

      should "have a contribution years from 2012 to 2013" do
        valid_years = Array(2012..2013)
        assert_same_elements valid_years, @cs.contribution_years_range
      end
    end

  end



  # Valid contributions

  context "An organization that has only one Posted contribution from a past year" do
    setup do
      @organization.contributions << create_contribution(raw_amount: 5000, stage: 'Posted', campaign_id: @campaign_past_year.id)
      @organization.contributions << create_contribution(raw_amount: 0, stage: 'Withdrawn', campaign_id: @campaign_this_year.id)
      @organization.contributions << create_contribution(raw_amount: 2500, stage: 'Pledged', campaign_id: @campaign_next_year.id)
    end

    should "still have the current annual contribution year" do
      # latest_annual_contribution_year
      assert_equal @cs.latest_annual_contribution_year, Date.today.year
    end

    should "have a valid contribution status for those years" do
      assert @cs.contributor_for_year?(Date.today.year - 2)
      # missing contribution for last year
      refute @cs.contributor_for_year?(Date.today.year - 1)
    end
  end

  # Lead companies

  context "An organization signed onto Global Compact Lead and has contributed for the current year" do
    setup do
      create_initiatives
      @campaign_lead_this_year = create_campaign(name: "LEAD #{Date.today.year}")
      @lead = Initiative.for_filter(:lead).first
      @lead.signings.create signatory: @organization
      @organization.contributions << create_contribution(raw_amount: 65000, stage: 'Posted', campaign_id: @campaign_lead_this_year.id)
    end

    should "be allowed to submit a Logo Request" do
      assert @cs.can_submit_logo_request?
    end
  end
end
