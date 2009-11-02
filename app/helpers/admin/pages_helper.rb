module Admin::PagesHelper
  def paged_pages
    @paged_pages ||= Page.paginate(:page => (params[:page] || 1), :order => 'updated_at DESC')
  end
  
  def pages_for_select
    @pages_for_select ||= Page.approved.map { |p| [p.title || p.path, p.id] }
  end
end
