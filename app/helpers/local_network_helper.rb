class LocalNetwork
  attr_accessor :country_code, :country
  
  def self.find(country_code)
    network = self.new
    network.country_code = country_code
    network.country = Country.find_by_code(country_code, :include => :organizations)
    network
  end
  
  def contacts
    unless @contacts
      @contacts = Contact.network_contacts.for_country(country).find(:all, :include => :roles)
      @contacts += [manager] if manager
    end
    @contacts
  end
  
  def latest_participant
    participants.last_joined.first
  end
  
  def manager
    @manager ||= country.manager
  end
  
  def name
    country.try :name
  end
  
  def url
    @organizer ||= country.organizations.local_network.first.try(:url)
  end
  
  def participants
    @participants ||= country.organizations.visible_in_local_network
  end
end

module LocalNetworkHelper
  
  def local_network
    unless @local_network
      if params[:path].last && params[:path].last.is_a?(String)
        country_code = params[:path].last.gsub(/\.html/, '')
        @local_network = LocalNetwork.find(country_code)
      end
    end
    @local_network
  end
  
  def p_with_link_to_local_network
    content_tag :p, "Website: #{link_to(local_network.url)}" unless local_network.url.blank?
  end
  
  def local_network_contacts
    local_network.contacts
  end
  
  def formatted_local_network_contact_info(contact)
    "#{role_for contact}<br />
    #{contact.full_name_with_title}<br />
    #{link_to contact.email, "mailto:#{contact.email}"}"
  end

  def p_with_link_to_participant_search
    content_tag :p, link_to("Participants in #{local_network.name}: #{local_network.participants.count}", '#FIXME') if local_network.participants.any?
  end
  
  def display_latest_participant_for_local_network
    if latest = local_network.latest_participant
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