module Admin::EventsHelper
  def event_date_range(event)
    "#{yyyy_mm_dd(event.starts_at)} - #{yyyy_mm_dd(event.ends_at)}"
  end
end
