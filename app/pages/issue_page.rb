class IssuePage < ContainerPage
  def hero
    (@data[:hero] || {}).merge({size: 'small'})
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def principles
    return Components::Principles.new(@data).data
  end

  def main_content_section
    @data[:issue_block] || {}
  end

  def sidebar_widgets
    Components::SidebarWidgets.new(@data)
  end

  def related_contents
    Components::RelatedContents.new(@data)
  end

  def resources
    Components::Resources.new(@data).data
  end

  def events
    Components::Events.new(@data)
  end

  def news
    Components::News.new(@data)
  end
end
