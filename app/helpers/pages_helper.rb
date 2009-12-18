module PagesHelper

  def per_page_select
    # ['Number of results per page', 10, 25, 50, 100]
    options = [
      ['Number of results per page', ''],
      ['10' , url_for(params.merge(:page => 1, :per_page => 10))],
      ['25' , url_for(params.merge(:page => 1, :per_page => 25))],
      ['50' , url_for(params.merge(:page => 1, :per_page => 50))],
      ['100', url_for(params.merge(:page => 1, :per_page => 100))]
    ]
    select_tag :per_page, options_for_select(options), :class => 'autolink'
  end

  def cop_link(cop, navigation=nil)
    if navigation
      cop_detail_with_nav_path(navigation, cop.id)
    else
      cop_detail_path(cop.id)
    end
  end

  def date_range(cop)
    "#{m_yyyy(cop.started_on)} - #{m_yyyy(cop.ended_on)}"    
  end

  # NOTE: Used to combine dynamic headlines with old, static content
  # if there are headlines for old years (< 2009) there will be
  # duplication of years on the archive page.
  def news_archive_years 
    # (2009..Date.today.year).to_a.reverse
    Headline.years
  end

  def participant_link(organization, navigation=nil)
    if navigation
      participant_with_nav_path(navigation, organization)
    else
      participant_path(organization)
    end
  end

  def versioned_edit_path
    if @current_version.approved?
      edit_page_path(:id => @page)
    else
      edit_page_path(:id => @page, :version => @current_version.version_number)
    end
  end

end
