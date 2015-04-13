class Components::LinksLists
  def initialize(data)
    @data = data
  end

  def data
    d = [@data[:widget_links_list]]
    if @data[:widget_call_to_action2]
      d.push(@data[:widget_links_list2])
    end
  end
end

