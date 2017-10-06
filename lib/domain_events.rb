module DomainEvents
  ActionPlatformOrderCreated = Class.new(RailsEventStore::Event)
  OrganizationSubscribbedToActionPlatform = Class.new(RailsEventStore::Event)

  OrganizationSelectedLevelOfParticipation = Class.new(RailsEventStore::Event)
  OrganizationInvoiceDateChosen = Class.new(RailsEventStore::Event)
  OrganizationParentCompanyIdentified = Class.new(RailsEventStore::Event)
  OrganizationAnnualRevenueChanged = Class.new(RailsEventStore::Event)
end
