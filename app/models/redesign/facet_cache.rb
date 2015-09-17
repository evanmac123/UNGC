class Redesign::FacetCache

  KEY = 'ungc-facet-cache'

  def initialize(redis)
    @redis = redis
  end

  def put(key, facets)
    @redis.hset(KEY, key, facets.to_json)
  end

  def fetch(key)
    json = @redis.hget(KEY, key)

    if json.nil?
      # cache miss
      put(key, yield)
      json = @redis.hget(KEY, key)
    end

    parse(json)
  end

  def delete(key)
    @redis.hdel(KEY, key)
  end

  def clear
    @redis.del(KEY)
  end

  private

  def parse(json)
    # converting to json, we loose symbolized keys at the top level
    # and our 2nd level keys are strings instead of integers
    # we can't change the interface now so we'll just have to convert
    # them back on the way out for now.
    JSON.parse(json).each_with_object({}) do |key_and_values, acc|
      facet_id, hash = key_and_values
      acc[facet_id.to_sym] = integerize_keys(hash)
    end
  end

  def integerize_keys(hash)
    return {} if hash.nil?
    hash.each_with_object({}) do |key_and_values, acc|
      key, values = key_and_values
      acc[key.to_i] = values
    end
  end

end
