module Admin::LocalNetworksHelper

  def link_to_public_profile(local_network)
    if local_network.country_code.present?
      link = "/NetworksAroundTheWorld/local_network_sheet/#{local_network.country_code}.html"
    else
      link = "/NetworksAroundTheWorld/"
    end
    popup_link_to 'View', link , {:title => "Public profile on the Global Compact website", :class => 'web_preview_large'}
  end
  
  def legal_status(local_network)
    local_network.sg_established_as_a_legal_entity ? "Established as legal entity" : "No legal status"
  end

  def link_to_local_network_document(file)
    file ? (link_to file.attachment.original_filename, file.attachment.url) : 'No file'
  end

  def subsidiary_participation(local_network)
    local_network.membership_subsidiaries ? "Yes, in Local Network activities" : "None"
  end
  
  def participant_fees(local_network)
    local_network.fees_participant ? "Member fees are required" : "Member fees are not required"
  end

end
