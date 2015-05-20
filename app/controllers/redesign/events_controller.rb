class Redesign::EventsController < Redesign::ApplicationController
  def index
    set_current_container_by_path '/take-action/events'
    @form = Redesign::EventsListForm.new(params[:page])
    @page = EventPage.new(current_container, current_payload_data, @form.results)
  end

  def show
    set_current_container_by_path '/take-action/events'
    @page = EventDetailPage.new(current_container, find_event)
  end

  # TODO this should be catchall
  def sponsorship
    set_current_container_by_path '/take-action/events/sponsorship'
    @page = ArticlePage.new(current_container, current_payload_data)
    render 'redesign/static/article'
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

end
