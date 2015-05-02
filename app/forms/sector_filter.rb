class SectorFilter < GroupedSearchFilter
  def initialize(selected_parents, selected_children, key: 'sectors')
    tree = Redesign::SectorTree.new
    super(tree, selected_parents)
    self.label = 'Sector'
    self.key = key
    self.child_key = 'sectors'
    self.selected_children = selected_children
  end
end
