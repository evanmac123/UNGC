class Event::Featured
  include Rails.application.routes.url_helpers

  def initialize(event)
    @event = event
  end

  def thumbnail_image_url
    @event.thumbnail_image.url
  end

  def starts_at
    @event.starts_at
  end

  def starts_at_iso8601
    starts_at.strftime('%F')
  end

  def full_location
    @event.full_location
  end

  def title
    @event.title
  end

  def short_description
    # TODO this is HTML, so truncate taking tags into consideration
    @event.description.truncate(200)
  end

  def path
    # HACK temporary hack to support the leader summit.
    # TODO find a proper solution if this type of feature is needed in the future
    if Feature.send_featured_events_to_landing?
      '/take-action/events/leaders-summit'
    else
      event_path(@event)
    end
  end

end

