WelcomePackage = Struct.new(:organization) do

  def link
    "/welcome/#{organization.organization_type_name_for_custom_links.gsub('_','-')}"
  end

end
