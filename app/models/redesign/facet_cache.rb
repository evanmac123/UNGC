class Redesign::FacetCache

  def initialize(redis)
    @redis = redis
  end

  def put(key, facets)
    @redis.set(key, facets.to_json)
  end

  def get(key)
    # converting to json, we loose
    # symbolized keys at the top level
    # and our 2nd level keys are strings instead of ints
    # we can't change the interface now so we'll just have to convert
    # them back on the way out for now.
    facets = @redis.get(key)
    if facets.present?
      JSON.parse(facets).each_with_object({}) do |pair, acc|
        key, value = pair
        acc[key.to_sym] = pair.each_with_object({}) do |key_and_value, hsh|
          k, v = key_and_value
          hsh[key.to_i] = v
        end
      end
    end
  end

  def delete(key)
    @redis.del(key)
  end

end
