class ArticlePage < ContainerPage
  def hero
    @data[:hero] || {}
  end

  def article_block
    article_block = @data[:article_block] || {}
    article_block[:widgets] = widgets
    article_block
  end

  def widgets
    widgets = {}

    widgets[:contact] = Components::Contact.new(@data).data

    widgets[:call_to_action] = Components::CallToActions.new(@data).data

    widgets[:links_list] = Components::LinksLists.new(@data).data

    widgets
  end


  def resources
    Components::Resources.new(@data).data
  end

  def events
    Components::Events.new(@data).data
  end
end

