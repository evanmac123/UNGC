module LocalNetworkHelper
  
  def local_network
    unless @local_network
      if params[:path].last && params[:path].last.is_a?(String)
        country_code = params[:path].last.gsub(/\.html/, '')
        @local_network = Country.find_by_code(country_code).local_network
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
    local_network.try(:network_contacts) || []
  end
  
  def formatted_local_network_contact_info(contact)
    return '&nbsp;' unless contact
    "#{role_for contact}<br />
    #{contact.full_name_with_title}<br />
    #{link_to contact.email, "mailto:#{contact.email}"}"
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
      content_tag :p, content
    end
  end
  
  def role_for(contact)
    return 'Global Compact Coordinator' if local_network.manager == contact
    possible = contact.roles.select { |r| Role.network_contacts.include?(r) }
    possible.try(:first).try(:name)
  end
  
  def link_to_annuaL_report_if_file_exists
    if local_network
      
      # get country code from path
      if params[:path].last && params[:path].last.is_a?(String)
        country_code = params[:path].last.gsub(/\.html/, '')
      end
      report_file = "public/docs/networks_around_world_doc/communication/network_reports/2009/#{country_code}.pdf"
      if FileTest.exists?(report_file)
        content_tag :p, link_to("#{local_network.try(:name)} (pdf)", "/docs/networks_around_world_doc/communication/network_reports/2009/#{country_code}.pdf")
      else
        'A report has not been provided'      
      end
      
    else
      return nil
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