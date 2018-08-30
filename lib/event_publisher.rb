class EventPublisher

  def self.publish(event, to:)
    client.publish_event(event, stream_name: to)
  end

  def self.client
    Rails.configuration.x_event_store
  end
end
