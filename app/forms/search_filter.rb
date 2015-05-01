class SearchFilter
  attr_accessor :tree, :type, :selected, :label, :parent_key, :child_key

  def initialize(tree, type, selected)
    @tree = tree
    @type = type
    @selected = selected
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

