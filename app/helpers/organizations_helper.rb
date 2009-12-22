module OrganizationsHelper
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
  
  def scoped_orgs(filter_type)
    Organization.participants.companies_and_smes.active.with_cop_status(filter_type)
  end
  
end