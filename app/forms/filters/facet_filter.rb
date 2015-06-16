class Filters::FacetFilter < SimpleDelegator

  def initialize(filter, facets)
    super(filter)
    @facets = facets
  end

  def options
    filter.select do |option|
      @facets.include?(option.id)
    end
  end

  private

  def filter
    __getobj__
  end

end
