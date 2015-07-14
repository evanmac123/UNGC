module ResourcesHelper
  def status_date(resource)
    resource.approved? ? resource.approved_at : resource.updated_at
  end

  def resource_sort_field(status)
    status == :approved ? 'approved_at' : 'updated_at'
  end

  def link_to_all_resources(reference)
    link_to 'View more resources', resources_path(commit: 'search', resource_search: { topic: {principle_ids: [Principle.find_by_reference(reference)]}}), class: 'view-all-resources'
  end

  def find_resources(ids)
    resources = Resource.find ids
    ids.collect { |id| resources.detect {|x| x.id == id} }
  end
end
