class Filters::GroupedSearchFilter < Filters::SearchFilter
  attr_accessor :selected_children

  def options
    items.map do |parent, children|
      child_options = children.map do |child|
        child_option(child)
      end
      [option(parent), child_options]
    end
  end

  def selected_options
    options.flatten.select(&:selected?)
  end

  private

  def option(parent)
    is_selected = selected.include?(parent.id)
    FilterOption.new(parent.id, parent.name, key, is_selected)
  end

  def child_option(child)
    is_selected = selected_children.include?(child.id)
    FilterOption.new(child.id, child.name, child_key, is_selected)
  end

end
