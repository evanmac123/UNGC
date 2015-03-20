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
    if contact
      html =  "#{role_for contact}<br />#{contact.full_name_with_title}"
      html += "<br />#{link_to contact.email, "mailto:#{contact.email}"}" unless contact.is?(Role.network_representative)
      html.html_safe
    end
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
      #{link_to latest.name, participant_link(latest), :title => latest.name}<br />
      Accepted on #{latest.joined_on.day} #{latest.joined_on.strftime('%B, %Y')}
      EOF
      content_tag :p, content.html_safe
    end
  end

  def role_for(contact)
    possible = contact.roles.select { |r| Role.network_contacts.include?(r) }
    possible.try(:first).try(:name)
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
    Organization.where_country_id(country_id).participants.collect {|o| o.id} || []
  end

  def cop_submitted_days_ago(days)
    limit = (Date.today - days.day).to_s
    today = (Date.today).to_s

    CommunicationOnProgress.approved
      .where('created_at BETWEEN (?) AND (?) AND organization_id in (?)', limit, today, organization_ids)
  end

  def cop_due_in_days(days)
    limit = (Date.today + days.day).to_s
    today = (Date.today).to_s

    Organization.where_country_id(country_id)
      .businesses.participants
      .with_cop_status(:active)
      .where('cop_due_on BETWEEN (?) AND (?)', today, limit)
  end

  def delisted_in_days(days)
    lower = (Date.today - 1.year).to_s
    upper = (Date.today - 1.year + days.day).to_s

    Organization.where_country_id(country_id)
      .businesses
      .participants
      .with_cop_status(:noncommunicating)
      .where('cop_due_on BETWEEN (?) AND (?)', lower, upper)
  end

  def participants_became_noncommunicating(days)
    limit = (Date.today - days.day).to_s
    today = (Date.today).to_s

    Organization.where_country_id(country_id)
      .businesses
      .participants
      .with_cop_status(:noncommunicating)
      .where('cop_due_on BETWEEN (?) AND (?)', limit, today)
  end

  def participants_became_delisted(days)
    limit = (Date.today - days.day).to_s
    today = (Date.today).to_s
    delisted = RemovalReason.delisted.try(:id)

    Organization.where_country_id(country_id)
      .businesses
      .participants
      .with_cop_status(:delisted)
      .where('delisted_on BETWEEN (?) AND (?) AND removal_reason_id = (?)', limit, today, delisted)
  end

  def participants_requesting_withdrawal
    # TODO this is broken and I don't think it's being used anymore.
    # if you are feeling brave, delete it.
    start_of_year = ("#{current_year}-01-01")
    today = (Date.today).to_s
    withdrawn = RemovalReason.withdrew.try(:id)

    Organization.where_country_id(country_id)
      .businesses
      .participants
      .with_cop_status(:delisted)
      .where('delisted_on BETWEEN (?) AND (?) AND removal_reason_id = (?)', start_of_year, today, withdrawn)
  end

  def approved_logo_requests(days)
    limit = (Date.today - days.day).to_s
    today = (Date.today).to_s
    LogoRequest.approved
      .where('approved_on BETWEEN (?) AND (?) AND organization_id in (?)', limit, today, organization_ids)
  end

end
