class EventPublisher

  def self.publish(event, to:)
    client = RailsEventStore::Client.new
    client.publish_event(event, stream_name: to)
  end
end
