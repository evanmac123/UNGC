module EventsHelper
  def current_month
    @current_date ||= Date.today
    @current_date.strftime '%B %Y'
  end
  
  def current_year
    nil
  end
  
  def this_months_events
    Event.events_for(@current_date.month, @current_date.year)
  end
end