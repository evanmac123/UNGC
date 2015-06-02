class Redesign::Searchable::SearchableEvent < Redesign::Searchable::Base
  alias_method :event, :model

  def self.all
    Event.approved
  end

  def document_type
    'Event'
  end

  def title
    event.title
  end

  def url
    redesign_event_path(event)
  end

  def content
    "#{strip_tags(event.description)} #{strip_tags(event.overview_description)}"
  end

  def meta
    event.taggings.map(&:content).join(' ')
  end

end
