module DomainEvents
  ActionPlatformOrderCreated = Class.new(RailsEventStore::Event)
  OrganizationSubscribbedToActionPlatform = Class.new(RailsEventStore::Event)
end
