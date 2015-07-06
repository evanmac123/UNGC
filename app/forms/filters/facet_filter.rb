class Filters::FacetFilter < SimpleDelegator
  attr_accessor :facet_key_from_option

  def initialize(filter, facets)
    super(filter)
    @facets = facets
    self.facet_key_from_option = ->(option) {option.id}
  end

  def options
    filter.select do |option|
      option_id = facet_key_from_option.call(option)
      @facets.include?(option_id)
    end
  end

  private

  def filter
    __getobj__
  end

end
