module Admin::OrganizationsHelper
  def organization_actions(organization)
    actions = []
    unless current_user.from_organization?
      actions << link_to('Network review', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_NETWORK_REVIEW), :method => :post) if organization.can_network_review?
      actions << link_to('Approve', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_APPROVE), :method => :post) if organization.can_approve?
      actions << link_to('Reject', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_REJECT), :method => :post) if organization.can_reject?
      actions << link_to('Reject Micro', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_REJECT_MICRO), :method => :post) if organization.can_reject?
      actions << link_to('Edit', edit_admin_organization_path(@organization.id), :title => 'Edit Profile')
      if @organization.participant 
        actions << link_to('Public profile', participant_path(@organization.id), :title => 'View public profile on website')
      end
    end
    actions.join(" | ")
  end
  
  def text_for_edit_icon(user)
    if user.from_organization?
      "Edit your organization's details"
    elsif user.from_network?
      "Edit this organization's details"
    else
      "Edit"
    end
  end
    
  def link_to_commitment_letter(organization)
    link_to_attached_file organization, 'commitment_letter'
  end
  
  def initial_organization_state(organization)
    commands = ["$('.company_only').#{organization.company? ? 'show' : 'hide'}();"]
    commands << "$('.public_company_only').#{organization.public_company? ? 'show' : 'hide'}();"
    commands.collect{|c| javascript_tag(c)}.join
  end

  def display_status(organization)

    if organization.approved? && organization.participant?
      # they've been approved, but only participants have a COP state
        if organization.delisted?
          status = "#{organization.delisted_on} (Delisted)"
        else
          status = organization.cop_state.humanize
        end
    elsif organization.network_review?
      status = current_user.from_organization? ? 'Your application is under review' : "Network Review: #{network_review_period(organization).downcase}"
    # if not approved then pending, in review, or rejected
    else
      status = organization.state.humanize
    end

  end
  
  def letter_of_commitment_updated(organization)
    if organization.commitment_letter_updated_at > organization.created_at
      "updated #{display_days_ago(organization.commitment_letter_updated_at)}"
    end
  end
  
  def network_review_period(organization)
    if organization.network_review_on + 7.days == Date.today
      content_tag :span, "Ends today", :style => 'color: green;'
    elsif Date.today - 7.days < organization.network_review_on
      "#{distance_of_time_in_words(Date.today - 7.days, organization.network_review_on)} remaining"
    else
      content_tag :span,
                  "#{distance_of_time_in_words(Date.today, organization.network_review_on + 7.days)} overdue",
                  :style => 'color: red;' 
    end
  end
    
  def display_id_type(organization)
    if organization.approved?
      if organization.participant?
        'Participant ID:'
      else
        'Organization ID:'
      end
    else
      'Application ID:'
    end
  end
    
  def local_network_detail(organization, detail)
    organization.country.try(:local_network) ? organization.country.try(:local_network).try(detail) : 'Unknown'
  end
  
  # display organizations with similar names
  def duplicate_application(organization)
    matches = Organization.search organization.name, :retry_stale => true, :stat => true 
    
    if matches.count > 0
      list_items = ''
      matches.try(:each) do |match|
        unless match.id == organization.id
          list_items += content_tag :li, link_to("#{match.id}: #{match.name}", admin_organization_path(match.id)), :title => "#{match.id}: #{match.name}"
        end
      end
    end
    
    unless list_items.blank?
      html = content_tag :span, 'We found organizations with similar names:', :style => 'color: green; display: block; margin: 3px 0px;'
      html += content_tag :ul, list_items, :class => 'matching_list'
    end
  end
  
end
