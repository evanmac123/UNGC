class HomePage < FakeHomePage
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
end
