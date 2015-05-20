class Filters::FlatSearchFilter < Filters::SearchFilter

  def options
    items.map do |item|
      FilterOption.new(item.id, item.name, key, selected.include?(item.id), label)
    end
  end

end
