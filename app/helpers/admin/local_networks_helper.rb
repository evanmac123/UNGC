module Admin::LocalNetworksHelper

  def link_to_social_media(local_network, link, title)
    if link == 'profile'
      url = popup_link_to 'Global Compact Profile', dashboard_link_to_public_profile(local_network)
    elsif link == 'website'
      url = popup_link_to 'Local Network Website', local_network.url if local_network.url.present?
    elsif local_network.send(link.to_s).send("present?")
      param = link == 'linkedin' ? 'in/' : '' # linkedin.com/in/username
      url = popup_link_to local_network.send(link.to_s), "http://#{link}.com/#{param}" + local_network.send(link.to_s)
    end
    content_tag(:dt, url, :class => "social #{link.to_s}", :title => title) if url
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

  def link_to_region_list(local_network)
    html = link_to local_network.region_name, admin_local_networks_path(:tab => local_network.region)
    html += "&nbsp;&nbsp;&#x25BA;&nbsp;".html_safe
  end

  def render_local_network_list_for_user(current_contact)
    if current_contact.from_ungc?
      render @local_networks
    else
      render @local_networks.active_networks
    end
  end

  def show_check(condition)
    condition ? 'checked' : 'unchecked'
  end

end
