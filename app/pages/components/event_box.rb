# takes an event and exposes the right data
# for content boxes to display

class Components::EventBox
  attr_reader :event

  def initialize(event)
    @event = event
  end

  def thumbnail
    event.thumbnail_image.url
  end

  def issue
    if event.is_online?
      'Online'
    elsif event.is_invitation_only?
      'Invitation'
    else
      'Open'
    end
  end

  def url
    Rails.application.routes.url_helpers.event_path(event)
  end

  def title
    event.title
  end

end
