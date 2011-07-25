module Admin::LocalNetworksHelper
  # We assign the Local Network from the country
  # def link_to_add_another_country(label)
  #   html = render(:partial => 'country')
  #   link_to_function(label, "$(\"#countries_list\").append('#{escape_javascript(html)}');")
  # end
  
  # This was placed in the Local Networks form  
  # %li
  #   = label_tag 'Countries'
  #   %li#countries_list
  #     - for country in @local_network.countries
  #       = render :partial => 'country', :locals => {:country => country}
  #   = link_to_add_another_country "Add Country"
    
end