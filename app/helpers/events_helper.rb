module EventsHelper
  def current_date
    unless @current_date
      today = Date.today
      month = (params[:month] || today.month).to_i
      year  = (params[:year]  || today.year ).to_i
      @current_date = Time.mktime(year, month, 1).to_date
    end
    @current_date
  end

  def current_month
    unless @current_month
      @current_month = current_date.strftime '%B %Y'
    end
    @current_month
  end

  def this_months_events
    @this_months_events ||= Event.approved.for_month_year(current_date.month, current_date.year)
  end

  def link_to_next_month?
    Event.approved.for_month_year(next_month.month, next_month.year).any?
  end

  def link_to_prev_month?
    Event.approved.for_month_year(prev_month.month, prev_month.year).any?
  end

  def next_month
    @next_month ||= current_date >> 1
  end

  def prev_month
    @prev_month ||= current_date << 1
  end

  def links_to_other_months(links=[])
    links << link_to(next_month.strftime('%B %Y'), url_for(:year => next_month.year, :month => next_month.month)) if link_to_next_month?
    links << link_to(prev_month.strftime('%B %Y'), url_for(:year => prev_month.year, :month => prev_month.month)) if link_to_prev_month?
    content_tag :p, links.join(' &bull; ')
  end

end
