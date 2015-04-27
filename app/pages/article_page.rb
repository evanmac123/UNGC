class ArticlePage < ContainerPage
  def hero
    (@data[:hero] || {}).merge({size: 'small', show_section_nav: true})
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def main_content_section
    @data[:article_block] || {}
  end

  def sidebar_widgets
    widgets = {}

    widgets[:contact] = Components::Contact.new(@data).data

    widgets[:calls_to_action] = Components::CallsToAction.new(@data).data

    widgets[:links_lists] = Components::LinksLists.new(@data).data

    widgets
  end


  def resources
    Components::Resources.new(@data).data
  end

  def events
    Components::Events.new(@data).data
  end
end

