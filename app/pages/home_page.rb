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
    Components::Events.new(@data, tier: :tier1)
  end

  def news
    Components::News.new(@data, news_type: :press_release)
  end

  def academies
    Components::Academies.new(@data)
  end
end
