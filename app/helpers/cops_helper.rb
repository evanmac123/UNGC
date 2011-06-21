module CopsHelper
  def check_if(condition)
    if condition
      image_tag 'checked.png'
    else
      '&nbsp;'
    end
  end
  
  def count_all_cops(filter_type=nil)
    scoped_cops(filter_type).count
  end
  
  # Does the search/filter via paginate
  def paged_cops(filter_type=nil)
    @paged_cops ||= {}
    @paged_cops[filter_type] ||= scoped_cops(filter_type).paginate(:per_page => params[:per_page] || 10, :page => params[:page] || 1)
    @paged_cops[filter_type]
  end
  
  # Produces the links
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
  
  def scoped_cops(filter_type)
    CommunicationOnProgress.send(filter_type).by_year
  end
end
