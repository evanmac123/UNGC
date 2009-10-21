class EventsController < ApplicationController
  helper :pages
  before_filter :determine_navigation
  before_filter :find_event

  def show
  end

  private
    def find_event
      @event = Event.find_by_id(params[:permalink].to_i)
      redirect_to(:permalink => @event.to_param) unless @event.to_param == params[:permalink]
      redirect_to(:back) unless @event
    end

    def default_navigation
      '/NewsAndEvents/Upcoming_Events.html'
    end
end
