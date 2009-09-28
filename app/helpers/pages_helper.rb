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

  def yyyy_mm_dd(date)
    date ? date.strftime('%Y/%m/%d') : '&nbsp;'
  end

  def versioned_edit_path
    if @current_version.approved?
      edit_content_path(:id => @page)
    else
      edit_content_path(:id => @page, :version => @current_version.number)
    end
  end

  # TODO: Are we using this anywhere?
  # def paged_participants(filter_type=nil)
  #   unless @paged_participants 
  #     @paged_participants = if filter_type # FIXME: Real pagination! @jaw6
  #       Organization.by_type(filter_type).find(:all, :limit => 20)
  #     else
  #       Organization.find(:all, :limit => 20)
  #     end
  #   end
  #   @paged_participants
  # end

end
