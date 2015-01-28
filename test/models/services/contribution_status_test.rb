require 'test_helper'

class FakeQuery
  def initialize(org)
  end
  def unique_campaigns
    []
  end
end

class ContributionStatusTest < ActionController::TestCase

  context "given a non delisted organization that contributed since 2010" do
    setup do
      org = stub(
        joined_on: Date.parse("2009-01-01"),
        delisted?: false,
        delisted_on: nil,
        signatory_of?: false
      )
      @p = ContributionStatus.new(org, FakeQuery)
    end

    should "have the proper latest_annual_contribution_year" do
      assert_equal @p.latest_annual_contribution_year, Date.today.year
    end

    should "have the proper initial_contribution_year" do
      assert_equal @p.initial_contribution_year, 2009
    end

    should "list all the years the organization has contributed" do
      FakeQuery.any_instance.stubs(unique_campaigns: [stub(name: "2010 Annual Contributions"),
                           stub(name: "2009 Annual Contributions"),
                           stub(name: "2013 Annual Contributions")])
      assert_equal @p.contributed_years.to_set, [2010, 2009, 2013].to_set
    end

    should "know if organization has contributed on a given year" do
      FakeQuery.any_instance.stubs(unique_campaigns: [stub(name: "2013 Annual Contributions")])

      assert @p.contributor_for_year?(2013), "has contributed should be true"
      refute @p.contributor_for_year?(2010), "has contributed should be false"
    end

    should "return the contribution years" do
      FakeQuery.any_instance.stubs(unique_campaigns: [stub(name: "2010 Annual Contributions"),
                           stub(name: "2009 Annual Contributions"),
                           stub(name: "2013 Annual Contributions")])
      assert_equal(@p.contribution_years, [
        {year: 2015, contributed: false},
        {year: 2014, contributed: false},
        {year: 2013, contributed: true},
        {year: 2012, contributed: false},
        {year: 2011, contributed: false},
        {year: 2010, contributed: true},
        {year: 2009, contributed: true}
      ])
    end
  end

  context "given an organization delisted in 2013" do
    setup do
      org = stub(
        joined_on: Date.parse("2010-01-01"),
        delisted?: true,
        delisted_on: Date.parse("2012-12-01"),
        signatory_of?: false
      )
      @p = ContributionStatus.new(org, FakeQuery)
    end

    should "have the proper latest_annual_contribution_year" do
      assert_equal @p.latest_annual_contribution_year, 2012
    end

    should "have the proper initial_contribution_year" do
      assert_equal @p.initial_contribution_year, 2010
    end
  end

  context" given an organization that already contributed for next year" do
    setup do
      org = stub(
        joined_on: Date.parse("2010-01-01"),
        delisted?: false,
        delisted_on: nil,
        signatory_of?: false
      )
      @p = ContributionStatus.new(org, FakeQuery)
      FakeQuery.any_instance.stubs(unique_campaigns: [stub(name: "2015 Annual Contributions"),
                           stub(name: "2016 Annual Contributions")])
    end

    should "have the proper latest_annual_contribution_year" do
      assert_equal @p.latest_annual_contribution_year, 2016
    end
  end

  context" given a LEAD organization" do
    setup do
      org = stub(
        joined_on: Date.parse("2010-01-01"),
        delisted?: false,
        delisted_on: nil,
      )
      org.expects(:signatory_of?).with(:lead).returns(true).at_least_once

      @p = ContributionStatus.new(org, FakeQuery)
      FakeQuery.any_instance.stubs(unique_campaigns: [stub(name: "LEAD 2015 Contributions"),
                           stub(name: "LEAD 2016 Contributions")])
    end

    should "have the proper latest_annual_contribution_year" do
      assert_equal @p.latest_annual_contribution_year, 2016
    end

    should "list all the years the organization has contributed" do
      assert_equal @p.contributed_years.to_set, [2015, 2016].to_set
    end
  end

  context "database tests" do
    setup do
      # We don't want to hard code years since these rules are year independent
      create_approved_organization_and_user
      @campaign_past_year = create_campaign(name: "#{Date.today.year - 2} Annual Contributions")
      @campaign_last_year = create_campaign(name: "#{Date.today.year - 1} Annual Contributions")
      @campaign_this_year = create_campaign(name: "#{Date.today.year} Annual Contributions")
      @campaign_next_year = create_campaign(name: "#{Date.today.year + 1} Annual Contributions")
      @cs = ContributionStatus.new(@organization)
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
end
