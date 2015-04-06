class HomePage
  def initialize(container, payload_data)
    @container = container
    @data      = payload_data || {}
  end

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
end
