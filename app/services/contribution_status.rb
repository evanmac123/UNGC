class ContributionStatus
  attr_reader :organization, :campaigns

  def initialize(organization, campaigns)
    @organization = organization
    @campaigns = campaigns
  end


  def can_submit_logo_request?
    return true if organization.non_business?
    years = Array((current_year - 1)..(current_year + 1))
    years.include?(latest_contributed_year)
  end

  # if an organization is currently delisted we stop at the last listed year
  # if an organization has already contributed for next year we use that
  # otherwise we iterate starting from the current year
  def latest_annual_contribution_year
    if organization.delisted?
      return organization.delisted_on.year
    end

    if contributor_for_year?(current_year + 1)
      return current_year + 1
    end

    current_year
  end

  def latest_contributed_year
    contributed_years.last
  end

  def contribution_years_range
    latest_annual_contribution_year.downto(initial_contribution_year)
  end

  def contributed_years
    campaigns.map(&:year).reject(&:nil?).sort
  end

  def contributor_for_year?(year)
    contributed_years.include?(year)
  end

  def initial_contribution_year
    year = organization.joined_on.try(:year)
    if year && year > 2006
      year
    else
      2006
    end
  end

  private

  def current_year
    Date.current.year
  end

end
