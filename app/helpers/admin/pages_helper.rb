module Admin::PagesHelper

  def is_page?(page_or_section)
    @is_page ||= {}
    @is_page[page_or_section] ||= @pages_and_sections_for.detect { |p| p.path == "#{params[:section] || '/'}#{page_or_section}" }
    @is_page[page_or_section]
  end

  def link_to_page_or_section(page_or_section)
    if page = is_page?(page_or_section)
      link_to page_or_section, find_page_by_path(:path => page.path)
    else
      link_to page_or_section, :section => "#{params[:section] || '/'}#{page_or_section}/"
    end
  end
  
  def paged_pages
    @paged_pages ||= Page.paginate(:page => (params[:page] || 1), :order => 'updated_at DESC')
  end

  def pages_and_sections_for(section)
    if section && section != '/'
      @pages_and_sections_for ||= Page.find(:all, :conditions => ["path like ?", "#{section}%"], :group => 'path')
    else
      @pages_and_sections_for ||= Page.find(:all, :group => 'path')
    end
    # sort: folders first, then alpha
    @pages_and_sections_for.map { |p| p.path.gsub(%r{\A#{(section || '/').gsub('/', '\/')}}, '').split('/').first }.uniq.sort_by { |p| [ is_page?(p) ? 1 : 0, p[0,2].downcase ] }
  end
  
  def pages_for_select
    @pages_for_select ||= Page.approved.map { |p| [p.title || p.path, p.id] }
  end

  def section_breadcrumbs
    sections = [['Home', {:section => nil}]]
    if params[:section]
      potential = params[:section].split('/')
      potential.shift # first is just the starting '/', which we already covered
      previously = ''
      potential.each { |p| sections << [p, {:section => "#{previously}/#{p}/"}]; previously = "#{previously}/#{p}" }
    end
    sections.map { |array| link_to_unless array == sections.last, array.first, array.last }.join(' / ')
  end
end
