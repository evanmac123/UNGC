module CopMailerHelper

  def link_to_local_network(org)
    if org.local_network_country_code
      "/NetworksAroundTheWorld/local_network_sheet/#{org.local_network_country_code}.html"
    else
      "/NetworksAroundTheWorld/"
    end
  end

  def local_network_name(org)
    if org.local_network_name.present?
      "Your Local Network in #{org.local_network_name}"
    else
      'Find your Local Network'
    end
  end

end
