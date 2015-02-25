class HomePage
  def initialize(container, payload_data)
    @container = container
    @data      = payload_data || {}
  end

  def get(key)
    @data[key.to_sym]
  end; alias_method :[], :get

  def main_links
    get(:main_links) || []
  end

  def stats
    get(:stats) || []
  end

  def event
    nil
  end
end
