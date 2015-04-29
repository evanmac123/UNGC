class AccordionPage < ContainerPage
  def hero
    (@data[:hero] || {}).merge({size: 'small', show_section_nav: true})
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def accordion
    accordion = OpenStruct.new(@data[:accordion])

    accordion.items.map! do |ni|
      if ni[:children]
        ni[:children].map!{|child| OpenStruct.new(child)}
      end
      OpenStruct.new(ni)
    end

    accordion
  end

  def sidebar_widgets
    Components::SidebarWidgets.new(@data)
  end
end

