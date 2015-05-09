class ListPage < ContainerPage
  def hero
    (@data[:hero] || {}).merge({size: 'small'})
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def list
    ListItems.new(@data[:list_block])
  end
end

class ListItems
  attr_reader :list_block

  def initialize(list_block)
    @list_block = list_block || {}
  end

  def items
    if sorting == 'desc'
      _items.reverse
    else
      _items
    end
  end

  def _items
    items = list_block[:items] || []
    items.map{|ni| OpenStruct.new(ni)}
  end

  def sorting
    list_block[:sorting]
  end

  def title
    list_block[:title]
  end

  def blurb
    list_block[:blurb]
  end
end
