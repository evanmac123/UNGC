module Admin::OrganizationsHelper
  def organization_actions(organization)
    actions = []
    unless current_contact.from_organization?
      actions << button_to('Network Review', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_NETWORK_REVIEW), :method => :post, :confirm => "The Local Network in #{@organization.country_name} will be emailed.\n\nAre you sure you want to proceed?\n\n", :class => "nobutton") if organization.can_network_review?
      actions << button_to('Delay Review', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_DELAY_REVIEW), :method => :post, :confirm => "This application will be put on hold", :class => "nobutton") if organization.can_delay_review?
      actions << button_to('Approve', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_APPROVE), {:method => :post, :class => "nobutton"}) if organization.can_approve?
      actions << button_to('Reject', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_REJECT), :method => :post, :confirm => "#{current_contact.first_name}, are you sure you want to reject this application?", :class => "nobutton") if organization.can_reject?
      actions << button_to('Reject Micro', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_REJECT_MICRO), :method => :post, :confirm => "#{current_contact.first_name}, are you sure you want to reject this Micro Enterprise?", :class => "nobutton") if organization.can_reject?
      actions << button_to('Edit', edit_admin_organization_path(@organization.id), :title => 'Edit Profile', :class => "nobutton")
      if @organization.participant
        actions << link_to('Public profile', participant_path(@organization.id), :title => 'View public profile on website')
      end
    end
    actions.join(" | ").html_safe
  end

  def cancel_and_return(current_contact)
    if current_contact.from_organization?
      dashboard_path
    else
      admin_organization_path @organization.id
    end
  end

  def text_for_edit_icon(user)
    if user.from_organization?
      "Edit your organization's profile"
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
    commands.collect{|c| javascript_tag(c)}.join.html_safe
  end

  def display_status(organization)

    if organization.approved? && organization.participant?

      # they've been approved, but only participants have a COP state
      if organization.delisted?
        status = "#{organization.delisted_on} (Delisted)"
      else
        status = organization.cop_state.humanize
      end

    elsif organization.in_review? || organization.delay_review?
      review_reason = " - #{organization.review_reason_value}" if organization.review_reason_value.present?
      status = current_contact.from_organization? ? 'Application is under review' : "#{organization.state.humanize}#{review_reason}"

    elsif organization.network_review?
      status = current_contact.from_organization? ? 'Application is under review' : "Network Review: #{network_review_period(organization).downcase}"

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
        'Participant ID'
      else
        'Organization ID'
      end
    else
      'Application ID'
    end
  end

  def local_network_detail(organization, detail)
    organization.country.try(:local_network) ? organization.country.try(:local_network).try(detail) : 'Unknown'
  end

  # display organizations with similar names
  def duplicate_application(organization)
    if ThinkingSphinx.sphinx_running?

      matches = Organization.search organization.name, :retry_stale => true, :stat => true
      if matches.count > 0
        list_items = ''
        matches.try(:each) do |match|
          unless match.id == organization.id
            list_items += content_tag :li,
                                      link_to("#{match.id}: #{match.name}",
                                      admin_organization_path(match.id)),
                                      :title => "#{match.id}: #{match.name}"
          end
        end
      end

      unless list_items.blank?
        html = content_tag :span, 'We found organizations with similar names:', :style => 'color: green; display: block; margin: 3px 0px;'
        html += content_tag :ul, list_items.html_safe, :class => 'matching_list'
      end
    end

  end

  def describe_peer_organizations(organization)
    if organization.company?
      "Companies from #{organization.country_name} in the #{organization.sector_name} sector."
    else
       "#{organization.organization_type_name} organizations from #{organization.country_name}"
    end
  end

  # if an organization is still under review, then they should be able to change their letter
  def can_edit_letter?(organization)
    unless organization.new_record? || organization.approved? && current_contact.from_organization?
      true
    end
  end

  def  alert_if_micro_enterprise(organization, current_contact)
    if current_contact.from_ungc?
      organization.business_entity? && organization.employees < 10 ? 'red' : 'inherit'
    end
  end

end
