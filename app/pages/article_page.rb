class ArticlePage < ContainerPage
  def hero
    @data[:hero] || {}
  end

  def main_content_section
    data = @data[:article_block] || {}
    data
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

