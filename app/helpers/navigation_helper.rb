module NavigationHelper
  def breadcrumbs
    unless @breadcrumbs
      @breadcrumbs = [ ['Home', '/'] ]
      @breadcrumbs << [current_section.title, current_section.path] if current_section
      @breadcrumbs << [@leftnav_selected.title, @leftnav_selected.path] if @leftnav_selected && current_section != @leftnav_selected
      @breadcrumbs << [@subnav_selected.title, nil] if @subnav_selected
      @breadcrumbs.map { |b| link_to_unless suppress_link(b), b.first, b.last }.join(' / ')
    end
  end

  def suppress_link(b)
    # Don't link to last item in breadcrumbs, but always link to 'Home'
    b == @breadcrumbs.last unless b.first == 'Home'
  end

  def child_selected?(navigation)
    @leftnav_selected && navigation.is_child_of?(@leftnav_selected)
  end

  def selected_elements_from_page(page)
    if page.parent
      @leftnav_selected = page.parent
      @subnav_selected  = page
    else
      @leftnav_selected = page
    end
  end

  def something_displayable_from(page)
    return nil unless page
    if @preview || page.display_in_navigation
      page
    else
      something_displayable_from page.parent
    end
  end

  def current_section
    unless @current_section
      return @current_section = nil if home_page?
      return @current_section = nil unless @page || @page = Page.approved_for_path(formatted_request_path)
      @current_section = @page.section
      if displayable = something_displayable_from(@page)
        selected_elements_from_page(displayable)
      end
    end
    @current_section
  end

  def is_visible?(child)
    if @preview
      child.display_in_navigation? && (child.approved? || (@page == child))
    else
      child.display_in_navigation?
    end
  end

  def leftnav_selected?(navigation)
    @leftnav_selected && navigation == @leftnav_selected
  end

  def path_matches?(navigation)
    navigation.path == formatted_request_path
  end

  def selected?(navigation)
    path_matches?(navigation) || leftnav_selected?(navigation) || child_selected?(navigation)
  end

  def sub_selected?(navigation)
    (@subnav_selected && @subnav_selected == navigation) || path_matches?(navigation)
  end

  def login_and_logout
    section_link = link_to('Login', login_path)
    children = []
    children << content_tag(:li, link_to('Reset Password', new_password_path)) unless logged_in?
    children << content_tag(:li, link_to('Logout', logout_path)) if logged_in?
    insides = section_link + "\n" + content_tag(:ul, children.join("\n  ") + "\n", :class => 'children') + "\n"
    content_tag(:li, insides, :id => 'login', :class => 'login') + "\n"
    # content_tag(:li, , :class => 'login')
  end

  def sections
    @sections ||= PageGroup.for_navigation #.find(:all)
  end

  def top_nav_bar(section_children_content='')
    sections.each do |section|
      section_link = content_tag :a, section.name, :href => section.visible_children.first.path #link_to_first_child
      children = section.visible_children.map do |child|
        child_link = content_tag :a, child.title, :href => child.path
        content_tag :li, child_link
      end
      insides = section_link + "\n" + content_tag(:ul, children.join("\n  ") + "\n", :class => 'children') + "\n"
      section_children_content << content_tag(:li, insides, :id => section.html_code, :class => section.html_code) + "\n"
    end
    section_children_content << login_and_logout
    content_tag :ul, "\n" + section_children_content
  end
end
