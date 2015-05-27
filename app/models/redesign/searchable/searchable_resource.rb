module Redesign::Searchable::SearchableResource
  def index_resource(resource)
    title = resource.title
    url = resource_url(resource)
    import 'Resource', url: url, title: title, content: content(resource), meta: tags(resource)
  end

  def content(resource)
    [
      resource.title,
      resource.description
    ].join(' ')
  end

  def tags(resource)
    (resource.issues.map(&:name) +
    resource.topics.map(&:name) +
    resource.sectors.map(&:name)).
    join(' ')
  end

  def indexable_resources
    Resource.approved
  end

  def index_resources
    indexable_resources.each { |r| index_resource r }
  end

  def index_resources_since(time)
    indexable_resources.where(new_or_updated_since(time)).each { |r| index_resource r }
  end

  def remove_resource(resource)
    remove 'Resource', resource_url(resource)
  end

  def resource_url(resource)
    with_helper { redesign_library_resource_path(resource) }
  end

end

