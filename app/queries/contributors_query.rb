class ContributorsQuery
  def self.contributors_for(year)
    annual_contribution = "#{year} Annual Contributions"
    lead_contribution = "LEAD #{year}%"
    Contribution.posted
      .joins(:campaign)
      .includes(:campaign, :organization)
      .merge(Organization.participants)
      .where("campaigns.name = ? or campaigns.name like ?", annual_contribution, lead_contribution)
  end
end
