require 'test_helper'

class ContributionStatusPresenterTest < ActionController::TestCase

  context "given a non delisted organization that contributed since 2010" do
    setup do
      org = stub(
        joined_on: Date.parse("2009-01-01"),
        delisted?: false,
        delisted_on: nil
      )
      @p = ContributionStatusPresenter.new(org)
      @p.stubs(campaigns: [])
    end

    should "have the proper start_year" do
      assert_equal @p.start_year, Date.today.year
    end

    should "have the proper initial_contribution_year" do
      assert_equal @p.initial_contribution_year, 2009
    end

    should "list all the years the organization has contributed" do
      @p.stubs(campaigns: [stub(name: "2010 Annual Contributions"),
                           stub(name: "2009 Annual Contributions"),
                           stub(name: "2013 Annual Contributions")])
      assert_equal @p.contributed_years.to_set, [2010, 2009, 2013].to_set
    end

    should "know if organization has contributed on a given year" do
      @p.stubs(campaigns: [stub(name: "2013 Annual Contributions")])

      assert @p.contributor_for_year?(2013), "has contributed should be true"
      refute @p.contributor_for_year?(2010), "has contributed should be false"
    end

    should "return the contribution years" do
      @p.stubs(campaigns: [stub(name: "2010 Annual Contributions"),
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
        delisted_on: Date.parse("2012-12-01")
      )
      @p = ContributionStatusPresenter.new(org)
      @p.stubs(campaigns: [])
    end

    should "have the proper start_year" do
      assert_equal @p.start_year, 2012
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
        delisted_on: nil
      )
      @p = ContributionStatusPresenter.new(org)
      @p.stubs(campaigns: [stub(name: "2015 Annual Contributions"),
                           stub(name: "2016 Annual Contributions")])
    end

    should "have the proper start_year" do
      assert_equal @p.start_year, 2016
    end
  end

end

