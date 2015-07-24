class EventsController < Redesign::ApplicationController
  def index
    set_current_container_by_path '/take-action/events'
    @search = EventsListForm.new(search_params)
    @page = EventPage.new(current_container, current_payload_data, @search.execute)
  end

  def show
    set_current_container_by_path '/take-action/events'
    @page = EventDetailPage.new(current_container, find_event)
  end

  private

  def find_event
    id = event_id_from_permalink
    Event.approved.find(id)
  end

  def event_id_from_permalink
    # to_i will convert the leading id portion to an int
    # or the whole thing it's just the id
    params.fetch(:id).to_i
  end

  def search_params
    params.fetch(:search, {})
      .permit(
        :start_date,
        :end_date,
        issues: [],
        topics: [],
        countries: [],
        types: []
      )
      .merge(page: page)
  end

  def page
    params.fetch(:page, 1).try(:to_i)
  end

end
