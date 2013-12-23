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

  # Due to the SME moratorium, we use the extended cop_due_on date for SMEs
  # Companies will conitinue to use the date determined by Organization#delisting_on
  def delisting_on(org)
    org.organization_type == OrganizationType.sme ? org.cop_due_on : org.delisting_on
  end

end
