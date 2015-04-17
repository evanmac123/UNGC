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
    data = @data[:issue_block] || {}
    data
  end

  def sidebar_widgets
    widgets = {}

    widgets[:contact] = Components::Contact.new(@data).data

    widgets[:calls_to_action] = Components::CallsToAction.new(@data).data

    widgets[:links_lists] = Components::LinksLists.new(@data).data

    widgets
  end

  def related_content
    Components::RelatedContent.new(@data)
  end

  def resources
    Components::Resources.new(@data).data
  end

  def events
    Components::Events.new(@data).data
  end
end
