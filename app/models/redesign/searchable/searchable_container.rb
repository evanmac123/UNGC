module Redesign::Searchable::SearchableContainer
  def index_container(container)
    title = container_title(container)
    url = container_url(container)
    import 'Container', url: url, title: title, content: container_content(container), meta: container_tags(container)
  end


  def container_title(container)
    # TODO extract json
    container.payload.data.try(:meta_tags).try(:title)
  end

  def container_description(container)
    container.payload.json_data
  end

  # TODO refactor all these methods with prefixes
  def container_content(container)
    [
      container_title(container),
      container_description(container)
    ].join(' ')
  end

  def container_tags(container)
    (container.issues.map(&:name) +
    container.topics.map(&:name) +
    container.sectors.map(&:name)).
    join(' ')
  end

  def indexable_containers
    Redesign::Container.where.not(public_payload_id: nil)
  end

  def index_containers
    indexable_containers.each { |r| index_container r }
  end

  def index_containers_since(time)
    indexable_containers.where(new_or_updated_since(time)).each { |r| index_container r }
  end

  def remove_container(container)
    remove 'Container', container_url(container)
  end

  def container_url(container)
    container.path
  end

end


