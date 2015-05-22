class Redesign::Admin::Api::EventsController < Redesign::Admin::ApiController

  def index
    events = Event.approved

    render_json events: events.map(&method(:serialize))
  end

  private

  def serialize(payload)
    EventSerializer.new(payload).as_json
  end
end
