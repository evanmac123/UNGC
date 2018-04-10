module Admin::OrganizationsHelper
  def organization_actions(organization)
    actions = []
    unless current_contact.from_organization?
      actions << button_to('Network Review', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_NETWORK_REVIEW), :method => :post, :data => { :confirm => "The Local Network in #{@organization.country_name} will be emailed.\n\nAre you sure you want to proceed?\n\n" }, :class => "nobutton") if organization.can_network_review?
      actions << button_to('Delay Review', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_DELAY_REVIEW), :method => :post, :data => { :confirm => "This application will be put on hold" }, :class => "nobutton") if organization.can_delay_review?
      actions << button_to('Approve', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_APPROVE), {:method => :post, :class => "nobutton"}) if organization.can_approve?
      actions << button_to('Reject', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_REJECT), :method => :post, :data => { :confirm => "#{current_contact.first_name}, are you sure you want to reject this application?" }, :class => "nobutton") if organization.can_reject?
      actions << button_to('Reject Micro', admin_organization_comments_path(@organization.id, :commit => ApprovalWorkflow::EVENT_REJECT_MICRO), :method => :post, :data => { :confirm => "#{current_contact.first_name}, are you sure you want to reject this Micro Enterprise?" }, :class => "nobutton") if organization.can_reject?
      actions << link_to('Edit', edit_admin_organization_path(@organization.id), :title => 'Edit Profile')

      staff_participant_manager_only do
        actions << link_to("Delete Organization", admin_organization_path(@organization.id), :title => 'Delete Profile', :data => {:confirm => 'Are you sure?'}, :method => :delete )
      end

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

  def initial_organization_state(organization)
    commands = ["$('.company_only').#{organization.company? ? 'show' : 'hide'}();"]
    commands << "$('.public_company_only').#{organization.public_company? ? 'show' : 'hide'}();"
    commands.collect{|c| javascript_tag(c)}.join.html_safe
  end

  def letter_of_commitment_updated(organization)
    if organization&.commitment_letter_updated_at > organization.created_at
      "updated #{display_days_ago(organization.commitment_letter_updated_at)}"
    end
  end

  def network_review_period(organization)
    if organization.network_review_on + 7.days == Date.current
      content_tag :span, "Ends today", :style => 'color: green;'
    elsif Date.current - 7.days < organization.network_review_on
      "#{distance_of_time_in_words(Date.current - 7.days, organization.network_review_on)} remaining"
    else
      content_tag :span,
                  "#{distance_of_time_in_words(Date.current, organization.network_review_on + 7.days)} overdue",
                  :style => 'color: red;'
    end
  end

  def local_network_detail(organization, detail)
    organization.country.try(:local_network) ? organization.country.try(:local_network).try(detail) : 'Unknown'
  end

  # display organizations with similar names
  def duplicate_application(organization)
    if Search.running?
      options = {retry_stale: true, stat: true, indices: ['organization_core']}
      matches = Organization.search(Riddle::Query.escape(organization.name), options)

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

  def alert_if_micro_enterprise(organization, current_contact)
    if current_contact.from_ungc?
      organization.business_entity? && organization.employees < 10 ? 'red' : 'inherit'
    end
  end

  def link_to_document(organization, document)
    html = ''
    html = file_field_tag "organization[#{document}_file]"
    if organization.send("#{document}")
      html += link_to truncate(@organization.send("#{document}").attachment_file_name, :length => 90), @organization.send("#{document}").attachment.url, {:title => @organization.send("#{document}").attachment_file_name}
    else
      html += "no file uploaded"
    end
    html.html_safe
  end

  # transplanted from the old participant_helper.rb

  def display_delisted_description(organization)
    organization.removal_reason == RemovalReason.delisted ? 'Reason for expulsion' : 'Reason for delisting'
  end

  def searched_for
    response = ''

    # Business search criteria
    if @searched_for[:business] == OrganizationType::BUSINESS
      # describe type of ownership
      ownership = ''
      if @searched_for[:listing_status_id].present?
        ownership = case ListingStatus.find(@searched_for[:listing_status_id]).name.downcase
          when 'publicly listed'
            # all FT500 companies are publicly traded
            @searched_for[:is_ft_500] ? 'FT 500' : 'publicly listed'
          when 'privately held'
            'privately held'
          when 'state-owned'
            'state-owned'
          when 'subsidiary'
            'subsidiary'
          else
            ownership = ''
        end
      end

      response << pluralize(@results.total_entries, ownership + ' business participant')
      response << " from #{countries_list}" unless @searched_for[:country_id].blank?

      if @searched_for[:sector_id].blank?
        response << ' in all sectors'
      else
        response << " in the #{Sector.find(@searched_for[:sector_id]).name} sector"
      end

      case @searched_for[:cop_state]
        when Zlib.crc32(Organization::COP_STATES[:active])
          response << ', with an Active COP status'
        when Zlib.crc32(Organization::COP_STATES[:noncommunicating])
          response << ', with a non-communicating COP status'
      end

    # Non-business search criteria
    elsif @searched_for[:business] == OrganizationType::NON_BUSINESS
      organization_type = OrganizationType.find_by_id(@searched_for[:organization_type_id])
      response << pluralize(@results.total_entries, 'non-business participant')
      response << " of type #{organization_type.try(:name) || 'unknown'}" unless @searched_for[:organization_type_id].blank?
      response << " from #{countries_list}" unless @searched_for[:country_id].blank?
    else
      response << pluralize(@results.total_entries, 'participant')
    end

    response << " from #{countries_list}" unless @searched_for[:country_id].blank? || !@searched_for[:business].blank?

    if @searched_for[:joined_on]
      response << " who were accepted between #{nice_date_from_param(:joined_after)} and #{nice_date_from_param(:joined_before)}"
    end

    response << " matching '#{@searched_for[:keyword]}'" unless @searched_for[:keyword].blank?
    response.html_safe
  end

  def link_to_add_social_network_fields(name, form)
    social_network = OrganizationSocialNetwork.new
    id = social_network.object_id
    fields = form.fields_for(:social_network_handles, social_network, child_index: id) do |f|
      render("social_network_handle_fields", f: f)
    end
    link_to(name, '', class: "add_fields", data: { id: id, fields: fields.gsub("\n", "")})
  end

  def excluded_by_criteria?(boolean)
    if boolean
      content_tag("span", "Yes", class: "danger")
    else
      "No"
    end
  end

  private

  def countries_list
    Country.find(params[:country]).map { |c| c.name }.sort.join(', ')
    countries = Country.find(params[:country]).map { |c| c.name }.sort
    join_items_into_sentance(countries)
  end

  def join_items_into_sentance(items)
    case items.length
      when 1
        items.first
      when 2
        items.join(' and ')
      else
        last_item = items.pop
        items.join(', ') + ' and ' + last_item
    end
  end

  def nice_date_from_param(join_date)
    params[join_date].to_date.strftime("%e&nbsp;%B,&nbsp;%Y")
  end
end
