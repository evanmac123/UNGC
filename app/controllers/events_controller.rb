class EventsController < ApplicationController
  helper :pages
  before_filter :determine_navigation
  before_filter :find_event

  def show
  end

  private
    def find_event
      @event = Event.find_by_id(params[:permalink].to_i)
      redirect_back_or_to and return unless @event
      redirect_to(:permalink => @event.to_param) unless @event.to_param == params[:permalink]
    end

    def default_navigation
      DEFAULTS[:upcoming_events_path]
    end
end
