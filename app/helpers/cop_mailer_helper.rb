module CopMailerHelper

  def link_to_local_network(org)
    if org.local_network_country_code
      "/NetworksAroundTheWorld/local_network_sheet/#{org.local_network_country_code}.html"
    else
      "/NetworksAroundTheWorld/"
    end
  end

end
