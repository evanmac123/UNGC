module Admin::LocalNetworksHelper

  def link_to_public_profile(local_network)
    if local_network.country_code.present?
      link = "/NetworksAroundTheWorld/local_network_sheet/#{local_network.country_code}.html"
    else
      link = "/NetworksAroundTheWorld/"
    end
  end

  def link_to_social_media(local_network, link, title)
    if link == 'profile'
      url = popup_link_to 'Global Compact Profile', link_to_public_profile(local_network)
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

  def current_user_can_edit_network?
    current_user.from_ungc? || (current_user.local_network == @local_network)
  end

  def link_to_region_list(local_network)
    html = link_to local_network.region_name, admin_local_networks_path(:tab => local_network.region), :class => 'dark_blue'
    html += "&nbsp;&nbsp;&#x25BA;&nbsp;"
  end

  def section_or_page_icon(page)
    if page.parent_id.present?
      image_tag "icons/Document_24x24.png", :title => "Page"
    else
      image_tag "icons/Folder (Open)_24x24.png", :title => "Section"
    end
  end

  def pending_or_approved_icon(page)
    if page == 'pending'
      image_tag "icons/Document_Edit_18x18.png"
    else
      image_tag "icons/Rate (Thumbs Up)_16x16.png"
    end
  end

  def announcement_count
    @announcements.count > 0 ? "(#{@announcements.count})" : ''
  end
end
