module NavigationHelper
  def current_section
    unless @current_section
      current_or_parent = Navigation.find_by_href(look_for_path)
      if current_or_parent
        @current_section = current_or_parent.parent ? current_or_parent.parent : current_or_parent
      end
    end
    @current_section
  end
  
  def selected?(navigation)
    navigation.href == look_for_path
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