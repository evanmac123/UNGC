module Admin::PagesHelper
  
  def sections
    @home = OpenStruct.new(name: 'Home')
    @pending = OpenStruct.new(name: 'Pending', id: 'pending')
    [@home, @pending] + PageGroup.all
  end
  
  def special_url_for(section)
    if section == @home
      admin_pages_path
    elsif section == @pending
      pending_admin_pages_path
    else
      admin_pages_path section: section.id
    end
  end
  
  def pending_or_home(section)
    logger.info " ** section: #{section} and pending: #{@pending}"
    if @section == 'pending'
      section == @pending
    else
      section == @home
    end
  end
  
  def link_to_section(section)
    if params[:section]
      link_to_unless params[:section].to_i == section.id, section.name, special_url_for(section) do |s| 
        "<strong>#{s}</strong>"
      end
    else # no section selected, probably at the 'root'
      link_to_unless pending_or_home(section), section.name, special_url_for(section) do |s| 
        "<strong>#{s}</strong>"
      end
    end
  end
  
  def create_new_section
    link_to 'Create new section', '#FIXME'
  end
  
  def pages_in_current_section
    if current_section
      current_section.children.approved.find(:all, conditions: { parent_id: nil }, order: 'position ASC') 
    elsif @section == 'pending'
      Page.with_approval('pending').all # FIXME
    else
      Page.approved.find(:all, conditions: { parent_id: nil, group_id: nil }, order: 'position ASC')
    end
  end
  
  def current_section
    @current_section ||= PageGroup.find(params[:section]) if params[:section]
  end
  
  def current_page
    if @section == 'pending'
      nil
    elsif params[:section].nil? && params[:page].nil? # we're looking at the home page
      @current_page = Page.approved.find_by_path('/index.html')
    elsif params[:page]
      @current_page ||= Page.find(params[:page]) 
    end
  end
  
  def current_subpage
    @current_subpage ||= Page.find(params[:subpage]) if params[:subpage]
  end
  
  def fancy_page_title(page)
    page.title ? page.title : "Untitled Page: #{page.path}"
  end
  
  def link_to_page(page)
    title = fancy_page_title(page)
    short = short_title(title)
    if should_highlight_page?(page)
      "<strong>%s</strong>" % short
    else
      url = page.pending? ? edit_admin_page_path(page) : admin_pages_path(section: page.group_id, page: page.id)
      link_to short, url, {title: title}
    end
  end
  
  def short_title(title)
    truncate title, 22
  end
  
  def create_new_page
    link_to 'Create new page', '#FIXME'
  end
  
  def create_new_subpage
    link_to 'Create new subpage', '#FIXME'
  end
  
  def link_to_subpage(subpage)
    title = fancy_page_title(subpage)
    short = short_title(title)
    if should_highlight_page?(subpage)
      "<strong>%s</strong>" % short
    else
      link_to short, admin_pages_path(section: subpage.group_id, page: subpage.parent_id, subpage: subpage.id), {title: title}
    end
  end
  
  def should_highlight_page?(page)
    page == current_page || page == current_subpage
  end
  
  def subpages_for_current_page
    return [] unless current_page
    current_page.children.approved.find(:all, order: 'position asc')
  end
  
  def link_to_parent(page)
    if parent = page.parent
      link_to parent.title, meta_admin_page_path(parent)
    elsif section = page.section
      link_to section.title, admin_pages_path(section: section.id)
    else
      link_to 'Site Root', admin_pages_path
    end
  end
  
  def pages_for_select
    []
  end
end
