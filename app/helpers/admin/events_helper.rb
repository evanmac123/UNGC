module Admin::EventsHelper
  def paged_events
    @paged_events ||= Event.paginate(:page => (params[:page] || 1),
                                     :order => order_from_params)
  end
  
  def date_range(event)
    "#{yyyy_mm_dd(event.starts_on)} - #{yyyy_mm_dd(event.ends_on)}"
  end
  
  def countries_for_select
    Country.find(:all, :order => 'name ASC').map { |c| [c.name, c.id] }
  end
end
