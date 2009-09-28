module OrganizationsHelper
  def organization_actions(organization)
    actions = []
    actions << link_to('Approve', approve_organization_path(@organization), :method => :post) if organization.can_approve?
    actions << link_to('Reject', reject_organization_path(@organization), :method => :post) if organization.can_reject?
    actions << link_to('Edit', edit_organization_path(@organization))
    actions << link_to('Back', organizations_path)
    actions.join(" | ")
  end

  def count_all_orgs(filter_type)
    Organization.with_cop_status(filter_type).count
  end
  
  def paged_organizations(filter_type)
    @paged_cops ||= {}
    @paged_cops[filter_type] ||= Organization.with_cop_status(filter_type).paginate(:per_page => params[:per_page] || 10, :page => params[:page] || 1)
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
  
end
