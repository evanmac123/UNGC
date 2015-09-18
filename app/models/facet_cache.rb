class FacetCache

  def initialize(cache_key = 'ungc-facet-cache')
    @cache_key
  end

  def put(key, facets)
    with_redis do |redis|
      redis.hset(cache_key, key, facets.to_json)
    end
  end

  def fetch(key, &default_value_block)
    json = with_redis do |redis|
      val = redis.hget(cache_key, key)

      if val.nil? && block_given?
        # cache miss
        put(key, default_value_block.call)
        redis.hget(cache_key, key)
      else
        val
      end
    end

    parse(json) unless json.nil?
  end

  def delete(key)
    with_redis do |redis|
      redis.hdel(cache_key, key)
    end
  end

  def clear
    with_redis do |redis|
      redis.del(cache_key)
    end
  end

  def count
    with_redis do |redis|
      redis.hlen(cache_key)
    end
  end

  private

  attr_reader :cache_key

  def with_redis
    UNGC::Redis.with_connection do |redis|
      yield redis
    end
  end

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
