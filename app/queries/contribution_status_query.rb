# Query Object that given an organization or an array of organizations
# returns ContributionStatuses for each organization
#
# the ContributionStatus is then used in LogoRequest(s) presenters and
# ContributionStatusPresenter to display information related to an
# organization and its contributions
class ContributionStatusQuery

  # returns an hash of the format
  # {
  #   organization.id => ContributionStatus for that organization,
  #   organization2.id => ContributionStatus for that organization,
  # }
  def self.for_organizations(organizations)
    a = {}
    c = campaigns(organizations)
    organizations.each do |o|
      camps = c[o.id] || Campaign.none
      a[o.id] = ContributionStatus.new(o, camps)
    end
    a
  end

  def self.for_organization(organization)
    c = Campaign.joins(:contributions).
      merge(Contribution.posted).
      where("contributions.organization_id = ?", organization.id).
      distinct(:'campaign.id')
    ContributionStatus.new(organization, c)
  end

  private

  def self.campaigns(organizations)
    Campaign.joins(:contributions).
      merge(Contribution.posted).
      select('campaigns.*, contributions.organization_id').
      where("contributions.organization_id IN (?)", organizations.map(&:id)).
      group(:'contributions.organization_id', 'campaigns.id').
      group_by do |c|
        c.organization_id
      end
  end
end
