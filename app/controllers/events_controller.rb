class EventsController < ApplicationController
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
    Event.approved.find(params.fetch(:id))
  end

  def search_params
    params.fetch(:search, {})
      .permit(
        :start_date,
        :end_date,
        issues: [],
        topics: [],
        countries: [],
        types: [],
        sustainable_development_goals: []
      )
      .merge(page: page)
  end

  def page
    params.fetch(:page, 1).try(:to_i)
  end

end
