class ContributionStatusPresenter
  def initialize(organization)
    @contributionStatus = ContributionStatus.new(organization)
  end

  # public api
  # returns array of {year: , contributed: } pairs
  def contribution_years
    @contributionStatus.contribution_years_range.inject([]) do |res, year|
      res.push({
        year: year,
        contributed: @contributionStatus.contributor_for_year?(year)
      })
    end
  end
end
