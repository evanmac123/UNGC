# frozen_string_literal: true

class Searchable::SearchableResource < Searchable::Base
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
    remove_redesign_prefix library_resource_path(resource)
  end

  def content
    resource.slice(:title, :description).values.join(' ')
  end

  def meta
    resource.taggings.includes(:author, :language, :initiative, :principle, :country).map(&:content).join(' ')
  end

end
