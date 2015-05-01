class SearchFilter
  attr_accessor :tree, :type, :label, :parents, :children, :selected

  def initialize(tree, type, label, parents, children)
    self.tree = tree
    self.type = type
    self.label = label
    self.parents = parents
    self.children = children
  end

  def select(selected)
    self.selected = selected
    self
  end

  def options
    tree.map do |parent, children|
      parent_option = FilterOption.new(parent.id, parent.name, type, selected.include?(parent.id))
      child_options = children.map do |child|
        FilterOption.new(child.id, child.name, type, selected.include?(child.id))
      end
      [parent_option, child_options]
    end
  end

end

