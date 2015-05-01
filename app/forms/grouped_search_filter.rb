class GroupedSearchFilter < SearchFilter

  def options
    items.map do |parent, children|
      parent_option = FilterOption.new(parent.id, parent.name, key, selected.include?(parent.id))
      child_options = children.map do |child|
        FilterOption.new(child.id, child.name, child_key, selected.include?(child.id))
      end
      [parent_option, child_options]
    end
  end

end
