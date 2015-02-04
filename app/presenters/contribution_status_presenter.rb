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

  def contribution_status_message
    @contribution_status.can_submit_logo_request? ? 'Contribution received' : "No contribution received for #{current_year} - #{current_year - 1}"
  end

  def can_submit_logo_request?
    @contribution_status.can_submit_logo_request?
  end

  private

  def current_year
    Date.today.year
  end
end
