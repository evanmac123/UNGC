class Filters::SectorFilter < Filters::GroupedSearchFilter
  def initialize(selected_parents, selected_children, key: 'sectors')
    super(SectorTree.new, selected_parents)
    self.selected_children = selected_children
    self.label = 'Sector'
    self.key = key
    self.child_key = 'sectors'
  end
end
