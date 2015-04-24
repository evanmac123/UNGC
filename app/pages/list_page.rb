class ListPage < ContainerPage
  def hero
    (@data[:hero] || {}).merge({size: 'small', show_section_nav: true})
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def list
    list = OpenStruct.new(@data[:list_block])

    list.items.map!{|ni| OpenStruct.new(ni)}

    list
  end
end
