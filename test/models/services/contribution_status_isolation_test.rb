require 'test_helper'

def create_annual_contribution_campaign(year)
  stub(name: "#{year} Annual Contributions", year: year)
end

def create_lead_contribution_campaign(year)
  stub(name: "LEAD #{year} Contributions", year: year)
end

def create_other_campaign
  stub(name: "Other campaign", year: nil)
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
      campaigns = [create_annual_contribution_campaign(2010),
                           create_annual_contribution_campaign(2009),
                           create_annual_contribution_campaign(2013)]
      @p = ContributionStatus.new(org, campaigns)
    end

    should "have the proper latest_annual_contribution_year" do
      assert_equal @p.latest_annual_contribution_year, Date.current.year
    end

    should "have the proper initial_contribution_year" do
      assert_equal @p.initial_contribution_year, 2009
    end

    should "list all the years the organization has contributed" do
      assert_equal @p.contributed_years.to_set, [2010, 2009, 2013].to_set
    end

    should "know if organization has contributed on a given year" do
      assert @p.contributor_for_year?(2013), "has contributed should be true"
      refute @p.contributor_for_year?(2012), "has contributed should be false"
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
      @p = ContributionStatus.new(org, [])
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
      travel_to Date.new(2015, 6, 1)
      org = stub(
        joined_on: Date.parse("2010-01-01"),
        delisted?: false,
        delisted_on: nil,
        signatory_of?: false
      )
      campaigns= [create_annual_contribution_campaign(2015), create_annual_contribution_campaign(2016)]
      @p = ContributionStatus.new(org, campaigns)
    end

    teardown do
      travel_back
    end

    should "have the proper latest_annual_contribution_year" do
      assert_equal @p.latest_annual_contribution_year, 2016
    end
  end

  context" given a LEAD organization" do
    setup do
      travel_to Date.new(2015, 6, 1)

      org = stub(
        joined_on: Date.parse("2010-01-01"),
        delisted?: false,
        delisted_on: nil,
      )

      @p = ContributionStatus.new(org, [create_lead_contribution_campaign(2015), create_lead_contribution_campaign(2016)])
    end

    teardown do
      travel_back
    end

    should "have the proper latest_annual_contribution_year" do
      assert_equal @p.latest_annual_contribution_year, 2016
    end

    should "list all the years the organization has contributed" do
      assert_equal @p.contributed_years.to_set, [2015, 2016].to_set
    end
  end

  context "given a non delisted organization that contributed to campaigns that don't match the rule" do
    setup do
      org = stub(
        joined_on: Date.parse("2009-01-01"),
        delisted?: false,
        delisted_on: nil,
        signatory_of?: false
      )
      campaigns = [create_annual_contribution_campaign(2010),
                           create_annual_contribution_campaign(2009),
                           create_annual_contribution_campaign(2013),
                           create_other_campaign]
      @p = ContributionStatus.new(org, campaigns)
    end

    should "list all the years the organization has contributed" do
      assert_equal @p.contributed_years.to_set, [2010, 2009, 2013].to_set
    end
  end

end
