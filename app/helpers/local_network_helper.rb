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
    content_tag :p, "Website: #{link_to(local_network.url,local_network.url)}" if local_network unless local_network.try(:url).blank?
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
      #{link_to latest.name, participant_link(latest)}<br />
      Joined on #{latest.joined_on.day} #{latest.joined_on.strftime('%B, %Y')}
      EOF
      content_tag :p, content
    end
  end
  
  def role_for(contact)
    return 'Global Compact Coordinator' if local_network.manager == contact
    possible = contact.roles.select { |r| Role.network_contact.include?(r) }
    possible.try(:first).try(:name)
  end
  
end