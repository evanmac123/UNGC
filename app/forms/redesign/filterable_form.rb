class Redesign::FilterableForm

  def filters
    []
  end

  def active_filters
    filters.flat_map(&:selected_options)
  end

  def disabled?
    false
  end

end
