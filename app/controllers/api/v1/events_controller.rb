class Api::V1::EventsController < ApplicationController
  before_action :doorkeeper_authorize!

  def index
    events = Event
                 .order("events.updated_at desc")
                 .paginate(per_page: per_page, page: page)

    response.headers['Current-Page']  = page.to_s
    response.headers['Per-Page']      = per_page.to_s
    response.headers['Total-Entries'] = organizations.count.to_s

    render json: {
        events: EventSerializer.wrap(events).as_json
    }
  end

  private

  def page
    params.fetch(:page, 1)
  end

  def per_page
    params.fetch(:per_page, 100)
  end
end
