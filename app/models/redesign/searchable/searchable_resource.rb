class Redesign::Searchable::SearchableResource < Redesign::Searchable::Base
  alias_method :resource, :model

  def self.all
    Resource.approved
  end

  def document_type
    'Resource'
  end

  def title
    resource.title
  end

  def url
    remove_redesign_prefix redesign_library_resource_path(resource)
  end

  def content
    resource.slice(:title, :description).values.join(' ')
  end

  def meta
    resource.taggings.map(&:content).join(' ')
  end

end
