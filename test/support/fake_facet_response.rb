class FakeFacetResponse

  def initialize()
    @facets = {}
  end

  def self.with(key, ids)
    self.new.tap do |resp|
      resp.add(key, ids)
    end
  end

  def add(key, ids)
    facets[key] = facet_counts(ids)
  end

  def facets(keywords = '', options = {})
    @facets
  end

  private

  def facet_counts(list, count = 1)
    list.each_with_object({}) do |item, hash|
      hash[item] = count
    end
  end

end
