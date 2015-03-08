class ContributionStatus
  YEAR_CAMPAIGN_REGEXP = /\A(?<year>\d\d\d\d) Annual Contributions\z/
  YEAR_LEAD_REGEXP = /\ALEAD (?<year>\d\d\d\d).*\z/

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

  def campaign_regexp
    if organization.signatory_of?(:lead)
      YEAR_LEAD_REGEXP
    else
      YEAR_CAMPAIGN_REGEXP
    end
  end

  def contributed_years
    campaigns.map do |c|
      c.name.match(campaign_regexp).try(:[], 1).try(:to_i)
    end.reject(&:nil?).sort
  end

  def contributor_for_year?(year)
    contributed_years.include?(year)
  end

  def initial_contribution_year
    organization.joined_on.year > 2006 ? organization.joined_on.year : 2006
  end

  private

  def current_year
    Date.today.year
  end

end
