class Components::SidebarWidgets
  def initialize(data)
    @data = data
  end

  def contact
    Components::Contact.new(@data).data
  end

  def calls_to_action
    Components::CallsToAction.new(@data).data
  end

  def links_lists
    Components::LinksLists.new(@data).data
  end
end
