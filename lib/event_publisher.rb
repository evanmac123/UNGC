class EventPublisher

  def self.publish(event, to:)
    Rails.configuration.x_event_store.publish_event(event, stream_name: to)
  end
end
