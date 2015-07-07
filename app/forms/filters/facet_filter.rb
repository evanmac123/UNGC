class Filters::FacetFilter < SimpleDelegator
  attr_reader :facets

  def initialize(filter, facets)
    super(filter)
    @facets = facets
  end

  def options
    filter.select do |option|
      include?(option)
    end
  end

  def include?(option)
    facets.include?(option.id)
  end

  private

  def filter
    __getobj__
  end

end
