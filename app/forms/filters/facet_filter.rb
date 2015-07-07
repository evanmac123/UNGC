class Filters::FacetFilter < SimpleDelegator
  attr_reader :facets

  def initialize(filter, facets)
    super(filter)
    @facets = facets
  end

  def options
    filter.select do |option|
      includes?(option)
    end
  end

  def includes?(option)
    facets.include?(option.id)
  end

  private

  def filter
    __getobj__
  end

end
