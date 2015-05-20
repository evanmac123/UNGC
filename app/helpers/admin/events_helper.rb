module Admin::EventsHelper
  def paged_events
    @paged_events ||= Event.paginate(:page => (params[:page] || 1),
                                     :order => order_from_params)
  end

  def event_date_range(event)
    "#{yyyy_mm_dd(event.starts_at)} - #{yyyy_mm_dd(event.ends_at)}"
  end

  def countries_for_select
    Country.data_for_select
  end
end
