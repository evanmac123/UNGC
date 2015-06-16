class Filters::FlatSearchFilter < Filters::SearchFilter

  def options
    items.map do |item|
      item_option(item)
    end
  end

  def select
    options.select do |option|
      yield(option)
    end
  end

  protected

  def item_option(item)
    FilterOption.new(item.id, item.name, key, selected.include?(item.id), label)
  end

end
