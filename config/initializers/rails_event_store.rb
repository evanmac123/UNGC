Rails.application.config.to_prepare do
  event_store = RailsEventStore::Client.new
  # subscribe to events here:
  # event_store.subscribe(handler, [events])
  Rails.configuration.x_event_store = event_store
end
