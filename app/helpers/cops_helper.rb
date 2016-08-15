module CopsHelper

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

  # TODO: Extracted from the now deleted PagesHelper. Maybe could be cleaned up later?
  def per_page_select(steps=[10,25,50,100,250])
    # ['Number of results per page', 10, 25, 50, 100]
    options = []
    steps.each do |step|
      options << ["#{step} results per page", url_for(params.merge(:page => 1, :per_page => step))]
    end
    selected = url_for(params.merge(:page => 1, :per_page => params[:per_page]))
    select_tag :per_page, options_for_select(options, :selected => selected), :class => 'autolink'
  end

  def count_all_orgs(filter_type)
    scoped_orgs(filter_type).count
  end

  def paged_organizations(filter_type)
    @paged_cops ||= {}
    @paged_cops[filter_type] ||= scoped_orgs(filter_type).paginate(:per_page => params[:per_page] || 10, :page => params[:page] || 1)
    @paged_cops[filter_type]
  end

  def paginate_orgs(filter_type=nil, options={})
    anchor = options.delete(:anchor)
    params = {}
    params.merge!(:anchor => anchor) if anchor
    will_paginate paged_organizations(filter_type),
      :previous_label => 'Previous',
      :next_label => 'Next',
      :page_links => false,
      :params => params
  end

  # Allows you to call a partial with a different format
  def with_format(format, &block)
    old_formats = formats
    self.formats = [format]
    content = block.call
    self.formats = old_formats
    content
  end

  def percent_issue_area_coverage(cop, principle_area)
    answer_count, question_count = cop.issue_area_coverage(PrincipleArea.send(principle_area).id, 'additional')
    if answer_count.to_i > 0 && question_count.to_i > 0
      ((answer_count.to_f / question_count.to_f) * 100).to_i
    else
      0
    end
  end

  def show_issue_area_coverage(cop, principle_area)
    answer_count, question_count = cop.issue_area_coverage(PrincipleArea.send(principle_area).id, 'additional')
    "#{answer_count} of #{question_count} items"
  end

  private

  def scoped_cops(filter_type)
    CommunicationOnProgress.send(filter_type).by_year
  end

  def scoped_orgs(filter_type)
    Organization.participants.companies_and_smes.send(filter_type)
  end

end
