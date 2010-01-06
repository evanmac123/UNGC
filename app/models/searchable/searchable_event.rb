module Searchable::SearchableEvent
  
  def index_event(event)
    title = event.title
    content = event.location + "\n" + 
      event.country.try(:name) + 
      with_helper {strip_tags(event.description)}
    url = with_helper { event_path(event) }
    import 'Event', url: url, title: title, content: content, object: event
  end

  def index_events
    Event.approved.each { |e| index_event e }
  end

  def index_events_since(time)
    Event.approved.find(:all, conditions: new_or_updated_since(time)).each { |e| index_event e }
  end

end