class HomePage < ContainerPage
  def hero
    @data[:hero] || {}
  end

  def tiles
    @data[:tiles] || []
  end

  def stats
    @data[:stats] || []
  end

  def events
    Components::Events.new(@data).data
  end

  def news
    Components::News.new(@data)
  end
end
