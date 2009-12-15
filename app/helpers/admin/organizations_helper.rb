module Admin::OrganizationsHelper
  def organization_actions(organization)
    actions = []
    unless current_user.from_organization?
      actions << link_to('Approve', admin_organization_comments_path(@organization.id, :commit => LogoRequest::EVENT_APPROVE.titleize), :method => :post) if organization.can_approve?
      actions << link_to('Reject', admin_organization_comments_path(@organization.id, :commit => LogoRequest::EVENT_REJECT.titleize), :method => :post) if organization.can_reject?
    end
    actions << link_to('Edit', edit_admin_organization_path(@organization.id))
    actions << link_to('Back', dashboard_path)
    actions.join(" | ")
  end
end
