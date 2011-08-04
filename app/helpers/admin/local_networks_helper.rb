module Admin::LocalNetworksHelper

  def link_to_public_profile(local_network)
    if local_network.country_code.present?
      link = "/NetworksAroundTheWorld/local_network_sheet/#{local_network.country_code}.html"
    else
      link = "/NetworksAroundTheWorld/"
    end
    link_to 'Public profile', link , :class => 'web_preview_large'
  end
  
  def subsidiary_participation(local_network)
    local_network.membership_subsidiaries ? "Yes, in Local Network activities" : "None"
  end

end