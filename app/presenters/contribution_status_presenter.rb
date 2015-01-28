class ContributionStatusPresenter
  YEAR_CAMPAIGN_REGEXP = /\A(?<year>\d\d\d\d) .*\z/
  YEAR_LEAD_REGEXP = /\ALEAD (?<year>\d\d\d\d).*\z/

  attr_reader :organization

  def initialize(organization)
    @organization = organization
  end

  # public api
  # returns array of {year: , contributed: } pairs
  def contribution_years
    contribution_years_range.inject([]) do |res, year|
      res.push({
        year: year,
        contributed: contributor_for_year?(year)
      })
    end
  end


  # if an organization is currently delisted we stop at the last listed year
  # if an organization has already contributed for next year we use that
  # otherwise we iterate starting from the current year
  def start_year
    if organization.delisted?
      return organization.delisted_on.year
    end

    if contributor_for_year?(current_year + 1)
      return current_year + 1
    end

    current_year
  end

  def contribution_years_range
    start_year.downto(initial_contribution_year)
  end

  def campaigns
    # TODO make sure we use only "posted" contributions
    @campaings ||= organization.contributions.includes(:campaign).map(&:campaign).uniq
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
      # TODO edit this to deal with lead organizations
      c.name.match(campaign_regexp).try(:[], 1).try(:to_i)
    end
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
