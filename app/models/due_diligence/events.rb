module DueDiligence
  module Events
    ReviewRequested = Class.new(RailsEventStore::Event)
    InfoAdded = Class.new(RailsEventStore::Event)
    CommentCreated = Class.new(RailsEventStore::Event)
    IntegrityReviewRequested = Class.new(RailsEventStore::Event)
    IntegrityApproval = Class.new(RailsEventStore::Event)
    IntegrityRejection = Class.new(RailsEventStore::Event)
    LocalNetworkInputRequested = Class.new(RailsEventStore::Event)
    Declined = Class.new(RailsEventStore::Event)
    Engaged = Class.new(RailsEventStore::Event)
  end
end
