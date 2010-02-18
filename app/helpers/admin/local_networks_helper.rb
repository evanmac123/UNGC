module Admin::LocalNetworksHelper
  def link_to_add_another_country(label)
    html = render(:partial => 'country')
    link_to_function(label, "$(\"#countries_list\").append('#{escape_javascript(html)}');")
  end
end