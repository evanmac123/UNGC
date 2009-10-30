module Admin::PagesHelper
  def paged_pages
    @paged_pages ||= Page.paginate(:page => (params[:page] || 1), :order => 'updated_at DESC')
  end

  def pages_and_sections_for(section)
    logger.info " ** #{section.inspect}"
    if section && section != '/'
      @pages_and_sections_for ||= Page.find(:all, :conditions => ["path like ?", "#{section}%"], :group => 'path')
    else
      @pages_and_sections_for ||= Page.find(:all, :group => 'path')
    end
    @pages_and_sections_for.map { |p| p.path.gsub(%r{\A#{(section || '/').gsub('/', '\/')}}, '').split('/').first }.uniq
  end
  
  def link_to_page_or_section(page_or_section)
    if page = @pages_and_sections_for.detect { |p| p.path == "#{params[:section] || '/'}#{page_or_section}" }
      link_to page_or_section, edit_admin_page_path(page)
    else
      link_to page_or_section, :section => "#{params[:section] || '/'}#{page_or_section}/"
    end
  end
  
  def pages_for_select
    @pages_for_select ||= Page.approved.map { |p| [p.title || p.path, p.id] }
  end
end
