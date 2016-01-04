class ContributorsQuery
  MIN_SEARCH_LENGTH = 3

  def self.search(query)
    if query.strip.length >= MIN_SEARCH_LENGTH
      lead_and_annual_contributions
        .where("organizations.name like ?", "%#{query}%")
    else
      Contribution.none
    end
  end

  def self.contributors_for(year)
    lead_and_annual_contributions(year)
  end

  private

  def self.lead_and_annual_contributions(year = "____")
    annual_contribution = "#{year} Annual Contributions"
    lead_contribution = "LEAD #{year}%"
    Contribution.posted
      .joins(:campaign)
      .includes(:campaign, :organization)
      .merge(Organization.participants)
      .where("campaigns.name LIKE ? or campaigns.name LIKE ?", annual_contribution, lead_contribution)
  end
end
