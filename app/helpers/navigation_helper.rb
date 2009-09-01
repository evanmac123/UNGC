module NavigationHelper
  def breadcrumbs
    breadcrumbs = [ ['Home', '/'] ]
    breadcrumbs << [current_section.label, current_section.href] if current_section
    breadcrumbs << [@leftnav_selected.label, @leftnav_selected.href] if @leftnav_selected && current_section != @leftnav_selected
    breadcrumbs << [@subnav_selected.label, nil] if @subnav_selected
    breadcrumbs.map { |b| link_to_unless b == breadcrumbs.last, b.first, b.last }.join(' / ')
  end
  
  def child_selected?(navigation)
    @leftnav_selected && navigation.is_child_of?(@leftnav_selected)
  end

  def current_section
    unless @current_section
      return nil if home_page?
      current_or_parent = Navigation.for_path(look_for_path)
      # if we're at the top, then it's us
      #   if we're in the middle, then it's our parent
      #     if we're on the bottom, then it's our parent's parent
      if current_or_parent.parent_id
        if current_or_parent.parent.parent_id # we're at the bottom
          @leftnav_selected = current_or_parent.parent
          @current_section = current_or_parent.parent.parent
          @subnav_selected = current_or_parent
        else # we're in the middle
          @current_section = current_or_parent.parent
          @leftnav_selected = current_or_parent
        end
      else # we're at the top, it's us
        @current_section = current_or_parent
      end
    end
    @current_section
  end
  
  def leftnav_selected?(navigation)
    @leftnav_selected && navigation == @leftnav_selected
  end

  def path_matches?(navigation)
    navigation.href == look_for_path
  end
  
  def selected?(navigation)
    path_matches?(navigation) || leftnav_selected?(navigation) || child_selected?(navigation)
  end
  
  def top_nav_bar(section_children_content='')
    Navigation.sections.each do |section|
      section_link = content_tag :a, section.label, :href => section.href
      children = section.children.map do |child|
        child_link = content_tag :a, child.label, :href => child.href
        content_tag :li, child_link
      end
      insides = section_link + "\n" + content_tag(:ul, children.join("\n  ") + "\n", :class => 'children') + "\n"
      section_children_content << content_tag(:li, insides, :id => section.short, :class => section.short) + "\n"
    end
    content_tag :ul, "\n" + section_children_content
  end
end