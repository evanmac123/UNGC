class Filters::SearchFilter
  attr_accessor :items, :selected, :label, :key, :child_key

  def initialize(items, selected)
    @items = items
    @selected = selected
  end

  def options
    [] # to override
  end

  def select(&block)
    options.select do |option|
      yield(option)
    end
  end

  def selected_options
    options.select(&:selected?)
  end

end
