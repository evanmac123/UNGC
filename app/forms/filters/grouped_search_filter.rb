class Filters::GroupedSearchFilter < Filters::SearchFilter
  attr_accessor :selected_children

  def options
    @options ||= items.map do |parent, children|
      child_options = children.map do |child|
        child_option(child)
      end
      [option(parent), child_options]
    end
  end

  def selected_options
    options.flatten.select(&:selected?)
  end

  ##
  # Includes all of the children of the parents
  # selected and any individual children selected outside of a parent
  def effective_selection_set
    ids = Set.new
    items.map do |parent, children|
      if selected.include?(parent.id)
        ids << parent.id
        ids += children.map(&:id)
      else
        ids += children.select do |child|
          selected_children.include?(child.id)
        end.map(&:id)
      end
    end
    ids.to_a
  end

  def select(&block)
    # filter out the children in the first pass
    # then filter out the parents without children in the next
    options.map do |parent, children|
      [parent, children.select(&block)]
    end.select do |parent, children|
      yield(parent) || children.any?
    end
  end

  private

  def option(parent)
    is_selected = selected.include?(parent.id)
    FilterOption.new(parent.id, parent.name, key, is_selected, label)
  end

  def child_option(child)
    is_selected = selected_children.include?(child.id)
    FilterOption.new(child.id, child.name, child_key, is_selected, label)
  end

end
