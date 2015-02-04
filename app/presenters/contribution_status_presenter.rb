class ContributionStatusPresenter
  def initialize(organization)
    @contribution_status = ContributionStatus.new(organization)
  end

  # public api
  # returns array of {year: , contributed: } pairs
  def contribution_years
    @contribution_status.contribution_years_range.inject([]) do |res, year|
      res.push({
        year: year,
        contributed: @contribution_status.contributor_for_year?(year)
      })
    end
  end

end
