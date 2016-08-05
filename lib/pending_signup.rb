class PendingSignup

  def initialize(session_id)
    @coder = Marshal
    @key = "pending-signup-#{session_id}"
  end

  def load
    with_redis do |redis|
      serialized = redis.get(@key)
      deserialize(serialized) unless serialized.nil?
    end
  end

  def store(signup)
    with_redis do |redis|
      redis.set(@key, serialize(signup))
    end
  end

  def clear
    with_redis do |redis|
      redis.del(@key)
    end
  end

  private

  def serialize(obj)
    Marshal.dump(obj)
  end

  def deserialize(str)
    Marshal.load(str)
  end

  def with_redis
    UNGC::Redis.with_connection do |redis|
      yield redis
    end
  end

end
