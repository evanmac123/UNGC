module Searchable::SearchableResource
  def index_resource(resource)
    title = resource.title
    content = [resource.title, resource.description].join(' ')
    url = resource_url(resource)
    import 'Resource', url: url, title: title, content: content, object: resource
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
    with_helper { resource_path(resource) }
  end

end
