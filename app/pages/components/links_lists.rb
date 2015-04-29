class Components::LinksLists
  def initialize(data)
    @data = data
  end

  def data
    @data[:widget_links_lists] || []
  end
end

