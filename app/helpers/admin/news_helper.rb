module Admin::NewsHelper
  def paged_headlines
    @paged_headlines ||= Headline.paginate(:page => (params[:page] || 1))
  end

  def date_range(headline)
    "#{yyyy_mm_dd(headline.starts_on)} - #{yyyy_mm_dd(headline.ends_on)}"
  end

  def countries_for_select
    [''] + Country.find(:all, :order => 'name ASC').map { |c| [c.name, c.id] }
  end
end
