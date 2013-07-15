module LocalNetworkHelper

  def local_network
    unless @local_network
      if params[:path].last && params[:path].last.is_a?(String)
        @country_code = params[:path].split("/").last.gsub(/\.html/, '')
        @local_network = Country.find_by_code(@country_code).local_network
      end
    end
    @local_network
  end

  def p_with_link_to_local_network
    if local_network and !local_network.try(:url).blank?
      content_tag :p, link_to(local_network.url, local_network.url)
    else
      nil
    end
  end

  def local_network_contacts
    local_network.try(:public_network_contacts) || []
  end

  def formatted_local_network_contact_info(contact)
    return '&nbsp;'.html_safe unless contact
    html =  "#{role_for contact}<br />#{contact.full_name_with_title}"
    html += "<br />#{link_to contact.email, "mailto:#{contact.email}"}" unless contact.is?(Role.network_representative)
    html.html_safe
  end

  def p_with_link_to_participant_search
    if local_network
      country_ids = local_network.countries.map(&:id)# { |c| "country_id[]=#{c.id}" }.join('&')
      content_tag :p, link_to("Participants in #{local_network.name}: #{local_network.participants.count}", participant_search_path(country: country_ids, commit: 't')) if local_network.participants.any?
    end
  end

  def display_latest_participant_for_local_network
    if local_network && latest = local_network.latest_participant
      content = <<-EOF
      Latest Participant:<br />
      #{link_to truncate(latest.name, :length => 45), participant_link(latest), :title => latest.name}<br />
      Accepted on #{latest.joined_on.day} #{latest.joined_on.strftime('%B, %Y')}
      EOF
      content_tag :p, content.html_safe
    end
  end

  def role_for(contact)
    return 'Global Compact Coordinator' if local_network.manager == contact
    possible = contact.roles.select { |r| Role.network_contacts.include?(r) }
    possible.try(:first).try(:name)
  end

  def link_to_annuaL_report_if_file_exists
    unless local_network.nil?
      html = ''
      [2011,2010,2009].each do |year|
        filename = "/docs/networks_around_world_doc/communication/network_reports/#{year}/#{@country_code}_#{year}.pdf"
        if FileTest.exists?("public/#{filename}")
          html += content_tag :li, link_to("#{year} #{local_network.try(:name)} Report", filename, {:class => 'pdf'})
        end
      end
     html.present? ? (content_tag :ul, html.html_safe, :class => 'links') : (content_tag :p, "No reports are available")
    end
  end

  def link_to_value_proposition_if_file_exists
    unless local_network.nil?
      html = ''
      [2011].each do |year|
        filename = "/docs/networks_around_world_doc/communication/network_reports/#{year}/#{@country_code}_VP.pdf"
        if FileTest.exists?("public/#{filename}")
          html += content_tag :li, link_to("#{local_network.try(:name)} - Value Proposition", filename, {:class => 'pdf'})
        end
      end
     html.present? ? (content_tag :ul, html.html_safe, :class => 'links') : (content_tag :p, "No document is available")
    end
  end

  def link_to_public_profile(local_network)
    if local_network.country_code.present?
      path = "/NetworksAroundTheWorld/local_network_sheet/#{local_network.country_code}.html"
      page = Page.find_by_path_and_approval path, 'approved'
      unless page.nil?
        link_to local_network.name, page.path
      else
        local_network.name
      end
    end
  end

  # temporary participant reports until Local Networks can login
  # these should be removed

  def country_id
    @country = Country.find_by_code(params[:country].to_s)
    @country.nil? ? nil : @country.id
  end

  def country_name
    Country.find(country_id).try(:name)
  end

  def organization_ids
    Organization.where_country_id([country_id]).participants.collect {|o| o.id} || []
  end

  def cop_submitted_days_ago(days)
    cops = CommunicationOnProgress.approved.find(:all,
      :conditions => ['created_at BETWEEN (?) AND (?) AND organization_id in (?)',
        (Date.today - days.day).to_s, (Date.today).to_s, organization_ids]
    )
  end

  def cop_due_in_days(days)
    Organization.where_country_id([country_id]).businesses.participants.with_cop_status(:active).find(
      :all, :conditions => ['cop_due_on BETWEEN (?) AND (?)', (Date.today).to_s, (Date.today + days.day).to_s]
    )
  end

  def delisted_in_days(days)
    Organization.where_country_id([country_id]).businesses.participants.with_cop_status(:noncommunicating).find(
      :all, :conditions => ['cop_due_on BETWEEN (?) AND (?)', (Date.today - 1.year).to_s, (Date.today - 1.year + days.day).to_s]
    )
  end

  def participants_became_noncommunicating(days)
    Organization.where_country_id([country_id]).businesses.participants.with_cop_status(:noncommunicating).find(
      :all, :conditions => ['cop_due_on BETWEEN (?) AND (?)', (Date.today - days.day).to_s, (Date.today).to_s]
    )
  end

  def participants_became_delisted(days)
    Organization.where_country_id([country_id]).businesses.participants.with_cop_status(:delisted).find(
      :all, :conditions => [ 'delisted_on BETWEEN (?) AND (?) AND removal_reason_id = (?)',
                            (Date.today - days.day).to_s, (Date.today).to_s, RemovalReason.delisted.id.to_i])
  end

  def participants_requesting_withdrawal()
    Organization.where_country_id([country_id]).businesses.participants.with_cop_status(:delisted).find(
      :all, :conditions => [ 'delisted_on BETWEEN (?) AND (?) AND removal_reason_id = (?)', ("#{current_year}-01-01"), (Date.today).to_s, RemovalReason.withdrew.id.to_i])
  end

  def approved_logo_requests(days)
    logo_requests = LogoRequest.approved.find(:all,
      :conditions => ['approved_on BETWEEN (?) AND (?) AND organization_id in (?)',
        (Date.today - days.day).to_s, (Date.today).to_s, organization_ids]
    )
  end

end
