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
    case local_network.sg_established_as_a_legal_entity
      when nil
        "Not reported"
       when true
         "Established as legal entity"
       when false
         "No legal status"
    end
  end

  def subsidiary_participation(local_network)
    case local_network.membership_subsidiaries
      when nil
        "Not reported"
       when true
         "Yes, in Local Network activities"
       when false
         "None"
    end
  end

  def participant_fees(local_network)
    case local_network.fees_participant
      when nil
        "Not reported"
      when true
        "Member fees are required"
      when false
        "Member fees are not required"
    end
  end

  def current_user_can_edit_network?
    current_user.from_ungc? || (current_user.local_network == @local_network)
  end
  
  def link_to_region_list(local_network)
    html = link_to local_network.region_name, admin_local_networks_path(:tab => local_network.region)
    html += "&nbsp;&nbsp;&#x25BA;&nbsp;"
  end

end
