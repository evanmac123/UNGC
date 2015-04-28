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
    widgets = {}

    widgets[:contact] = Components::Contact.new(@data).data

    widgets[:calls_to_action] = Components::CallsToAction.new(@data).data

    widgets[:links_lists] = Components::LinksLists.new(@data).data

    widgets
  end
end

