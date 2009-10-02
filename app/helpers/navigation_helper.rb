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

  def current_section
    unless @current_section
      return nil if home_page?
      return nil unless current_or_parent = Page.find_by_path(look_for_path)
      logger.info " ** #{current_or_parent.inspect}"
      # if we're at the top, then it's our group
      # if we're a sub-page, then it's our parent's group
      if current_or_parent.parent_id
        @leftnav_selected = current_or_parent.parent
        @subnav_selected  = current_or_parent
        @current_section  = current_or_parent.parent.section
      else
        @leftnav_selected = current_or_parent
        @current_section  = current_or_parent.section
      end
    end
    @current_section
  end
  
  def leftnav_selected?(navigation)
    @leftnav_selected && navigation == @leftnav_selected
  end

  def path_matches?(navigation)
    navigation.path == look_for_path
  end
  
  def selected?(navigation)
    path_matches?(navigation) || leftnav_selected?(navigation) || child_selected?(navigation)
  end
  
  def login_and_logout
    section_link = link_to('Login', login_path)
    children = []
    children << content_tag(:li, link_to('Logout', logout_path)) if logged_in?
    insides = section_link + "\n" + content_tag(:ul, children.join("\n  ") + "\n", :class => 'children') + "\n"
    content_tag(:li, insides, :id => 'login', :class => 'login') + "\n"
    # content_tag(:li, , :class => 'login')
  end
  
  def top_nav_bar(section_children_content='')
    PageGroup.for_navigation.each do |section|
      section_link = content_tag :a, section.name, :href => section.link_to_first_child
      children = section.children.map do |child|
        child_link = content_tag :a, child.title, :href => child.path
        content_tag :li, child_link
      end
      insides = section_link + "\n" + content_tag(:ul, children.join("\n  ") + "\n", :class => 'children') + "\n"
      section_children_content << content_tag(:li, insides, :id => section.slug, :class => section.slug) + "\n"
    end
    section_children_content << login_and_logout
    content_tag :ul, "\n" + section_children_content
  end
end