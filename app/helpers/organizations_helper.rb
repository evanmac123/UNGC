module OrganizationsHelper
  def organization_actions(organization)
    actions = []
    actions << link_to('Approve', approve_organization_path(@organization), :method => :post) if organization.pending?
    actions << link_to('Reject', reject_organization_path(@organization)) if organization.pending?
    actions << link_to('Edit', edit_organization_path(@organization))
    actions << link_to('Back', organizations_path)
    actions.join(" | ")
  end
end
