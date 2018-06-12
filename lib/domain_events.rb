module DomainEvents
  ActionPlatformOrderCreated = Class.new(RailsEventStore::Event)
  OrganizationSubscribbedToActionPlatform = Class.new(RailsEventStore::Event)

  OrganizationSelectedLevelOfParticipation = Class.new(RailsEventStore::Event)
  OrganizationInvoiceDateChosen = Class.new(RailsEventStore::Event)
  OrganizationParentCompanyIdentified = Class.new(RailsEventStore::Event)
  OrganizationAnnualRevenueChanged = Class.new(RailsEventStore::Event)

  # Coarse, A/R callback events
  # Ideally in the future these will be fired from a place in the code
  # to provide more context around the intent of the change:
  # (OrganizationApproved, OrganizationExpelled etc). This would include
  # controllers and background processes for example. These coarse grained
  # events leave it up to the reciever to infer intent and that's not great.
  OrganizationImported = Class.new(RailsEventStore::Event)
  OrganizationCreated = Class.new(RailsEventStore::Event)
  OrganizationUpdated = Class.new(RailsEventStore::Event)
  OrganizationDestroyed = Class.new(RailsEventStore::Event)

  ContactImported = Class.new(RailsEventStore::Event)
  ContactCreated = Class.new(RailsEventStore::Event)
  ContactUpdated = Class.new(RailsEventStore::Event)
  ContactDestroyed = Class.new(RailsEventStore::Event)

  LocalNetworkImported = Class.new(RailsEventStore::Event)
  LocalNetworkCreated = Class.new(RailsEventStore::Event)
  LocalNetworkUpdated = Class.new(RailsEventStore::Event)
  LocalNetworkDestroyed = Class.new(RailsEventStore::Event)
end
