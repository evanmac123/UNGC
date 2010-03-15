module Admin::OrganizationsHelper
  def organization_actions(organization)
    actions = []
    unless current_user.from_organization?
      actions << link_to('Network review', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_NETWORK_REVIEW), :method => :post) if organization.can_network_review?
      actions << link_to('Approve', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_APPROVE), :method => :post) if organization.can_approve?
      actions << link_to('Reject', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_REJECT), :method => :post) if organization.can_reject?
    end
    actions << link_to('Edit', edit_admin_organization_path(@organization.id))
    actions.join(" | ")
  end
  
  def link_to_commitment_letter(organization)
    link_to_attached_file organization, 'commitment_letter'
  end
  
  def initial_organization_state(organization)
    commands = ["$('.company_only').#{organization.company? ? 'show' : 'hide'}();"]
    commands << "$('.public_company_only').#{organization.public_company? ? 'show' : 'hide'}();"
    commands.collect{|c| javascript_tag(c)}.join
  end
  
  def show_delisted_details(organization)
    organization.active ? 'none' : 'block'
  end
  
end
