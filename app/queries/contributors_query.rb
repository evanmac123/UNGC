class ContributorsQuery
  def self.contributors_for(year)
    annual_contribution = "#{year} Annual Contributions" #TODO bug with the pattern
    lead_contribution = "LEAD #{year}%"
    Contribution.posted
      .joins(:campaign)
      .includes(:campaign, :organization)
      .where("campaigns.name like ? or campaigns.name like ?", annual_contribution, lead_contribution)
  end
end
