class ContributionStatusPresenter
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

  private

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
    @campaings ||= organization.contributions.includes(:campaign).map(&:campaign).uniq
  end

  def contributed_years
    campaigns.map(&:name).map(&method(:get_year)).flatten.map(&:to_i)
  end

  def contributor_for_year?(year)
    contributed_years.include?(year)
  end

  def initial_contribution_year
    organization.joined_on.year > 2006 ? organization.joined_on.year : 2006
  end

  # used as proc object
  def get_year(s)
    # TODO edit this to deal with lead organizations
    s.match(/(?<year>\d\d\d\d) .*/).try(:values_at, 1)
  end

  def current_year
    Date.today.year
  end

end
