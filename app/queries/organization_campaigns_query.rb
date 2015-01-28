class OrganizationCampaignsQuery
  attr_reader :organization

  def initialize(organization)
    @organization = organization
  end

  def unique_campaigns
    Campaign.joins(:contributions).
      merge(Contribution.posted).
      where("contributions.organization_id = ?", organization.id).
      distinct(:'campaign.id')
  end
end
