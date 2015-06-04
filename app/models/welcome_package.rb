WelcomePackage = Struct.new(:organization, :has_redesign?) do

  def link
    if has_redesign?
      "/welcome/#{organization.organization_type_name_for_custom_links.gsub('_','-')}"
    else
      "/GettingStarted#{organization.organization_type_name_for_custom_links.camelize}/introduction.html"
    end
  end

end
