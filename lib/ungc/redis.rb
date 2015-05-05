module UNGC
  class Redis
    def self.with_connection(&block)
      Sidekiq.redis(&block)
    end
  end
end
