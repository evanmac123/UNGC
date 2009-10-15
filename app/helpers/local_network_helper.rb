class LocalNetwork
  attr_accessor :country_code, :country
  
  def self.find(country_code)
    network = self.new
    network.country_code = country_code
    network.country = Country.find_by_code(country_code)
    network
  end
  
  def contacts
    @contacts ||= Contact.network_contacts_for(country).find(:all, :include => :role)
  end
 # def contacts
 #   organizer.contacts.network_contacts
 # end
   
  def name
    country.try :name
  end
  
  def organizer
    @organizer ||= participants.by_type(:gc_networks).first
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
    "#{contact.role_name}<br />
    #{contact.full_name_with_title}<br />
    #{link_to contact.email, "mailto:#{contact.email}"}"
  end

  def p_with_link_to_participant_search
    content_tag :p, link_to("Participants in #{local_network.name}: #{local_network.participants.count}", '#FIXME') if local_network.participants.any?
  end
  
  def display_latest_participant_for_local_network
    
  end
  
  
end