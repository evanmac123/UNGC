class LocalNetwork
  attr_accessor :country_code
  
  def self.find(country_code)
    network = self.new
    network.country_code = country_code
    network
  end
  
  def organizer
    @organizer ||= participants.by_type(:gc_networks).first
  end
  
  def contacts
    organizer.contacts.network_contacts
  end
  
  def participants
    @participants ||= Organization.network_participants_for(country)
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
    content_tag :p, "Website: #{link_to(local_network.organizer.url)}" unless local_network.organizer.url.blank?
  end
  
  def local_network_contacts
    logger.info " ** #{local_network.contacts.inspect}"
    local_network.contacts
  end
  
  def formatted_local_network_contact_info(contact)
    contact.name
  end

  def p_with_link_to_participant_search
    
  end
  
  def display_latest_participant_for_local_network
    
  end
  
  
end