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
    if organization.commitment_letter?
      if organization.commitment_letter_file_name.downcase.ends_with?('.pdf')
        file_type = 'PDF'
      elsif organization.commitment_letter_file_name.downcase.ends_with?('.doc') || 
        organization.commitment_letter_file_name.downcase.ends_with?('.docx')
        file_type = 'Word'
      else
        file_type = 'Other'
      end
      # TODO: We need a generic file type icon
      link_to "#{file_type} document", organization.commitment_letter.url, :class => "#{file_type.downcase}_doc",
                                                                           :title => "Download #{file_type} document"
    end
  end
end
