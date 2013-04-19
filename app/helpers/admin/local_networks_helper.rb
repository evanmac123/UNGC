module Admin::LocalNetworksHelper

  def dashboard_link_to_public_profile(local_network)
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

  def current_contact_can_edit_network?
    current_contact.from_ungc? || (current_contact.local_network == @local_network)
  end

  def link_to_region_list(local_network)
    html = link_to local_network.region_name, admin_local_networks_path(:tab => local_network.region)
    html += "&nbsp;&nbsp;&#x25BA;&nbsp;".html_safe
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

end
