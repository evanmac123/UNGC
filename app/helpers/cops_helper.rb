module CopsHelper
  def count_all_cops(filter_type=nil)
    CommunicationOnProgress.for_filter(filter_type).count
  end
  
  def paged_cops(filter_type=nil)
    @paged_cops ||= {}
    @paged_cops[filter_type] ||= CommunicationOnProgress.for_filter(filter_type).by_year.paginate(:per_page => params[:per_page] || 10, :page => params[:page] || 1)
    @paged_cops[filter_type]
  end
  
  def paginate_cops(filter_type=nil, options={})
    anchor = options.delete(:anchor)
    params = {}
    params.merge!(:anchor => anchor) if anchor
    will_paginate paged_cops(filter_type), 
      :previous_label => 'Previous',
      :next_label => 'Next',
      :page_links => false, 
      :params => params
  end
  
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
end
