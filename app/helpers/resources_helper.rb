module ResourcesHelper
  def languages_for_select(selected_language=nil)
    options_for_select(Language.all.map { |c| [c.name, c.id] }, selected: selected_language)
  end

  def resource_sort_by
    # ['Number of results per page', 10, 25, 50, 100]
    options = [
      ["sort by title", url_for(params.merge(:order => "title asc"))],
      ["sort by Year", url_for(params.merge(:order => "year desc"))],
      ["sort by ISBN", url_for(params.merge(:order => "isbn asc"))]
    ]
    selected = url_for(params.merge(:order => params[:order]))
    select_tag :per_page, options_for_select(options, :selected => selected), :class => 'autolink'
  end

end
