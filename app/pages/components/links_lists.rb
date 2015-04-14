class Components::LinksLists
  def initialize(data)
    @data = data
  end

  def data
    # XXX links_list will be an array in the payload once we add proper
    # validation support for nested arrays to the cms
    d = @data[:widget_links_list]
    if d
      [d]
    else
      []
    end
  end
end

