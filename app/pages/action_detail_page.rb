class ActionDetailPage < ContainerPage
  def hero
    (@data[:hero] || {}).merge({size: 'small', show_section_nav: false})
  end

  def principles
    return Components::Principles.new(@data).data
  end

  def main_content_section
    @data[:action_detail_block] || {}
  end

  def sidebar_widgets
    Components::SidebarWidgets.new(@data)
  end

  def related_contents
    Components::RelatedContents.new(@data)
  end

  def resources
    Components::Resources.new(@data).data
  end

  def events
    Components::Events.new(@data)
  end

  def news
    Components::News.new(@data)
  end

  def partners
    Components::Partners.new(@data).data
  end

  def participants
    Components::Participants.new(@data)
  end
end
