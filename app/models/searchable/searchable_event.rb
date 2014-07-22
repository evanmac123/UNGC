module Searchable::SearchableEvent

  def index_event(event)
    title = event.title
    country = event.country.try(:name)
    description = with_helper {strip_tags(event.description)}
    content = "#{event.location}\n#{country}#{description}"
    url = event_url(event)
    import 'Event', url: url, title: title, content: content, object: event
  end

  def index_events
    Event.approved.each { |e| index_event e }
  end

  def index_events_since(time)
    Event.approved.find(:all, conditions: new_or_updated_since(time)).each { |e| index_event e }
  end

  def remove_event(event)
    remove 'Event', event_url(event)
  end

  def event_url(event)
    with_helper { event_path(event) }
  end

end
