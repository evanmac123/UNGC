class DueDiligence::ReviewPolicy

  attr_reader :review

  def initialize(review)
    @review = review
  end

  def self.from_integrity?(contact)
    contact.is?(Role.integrity_team_member) || from_integrity_managers?(contact)
  end

  def self.from_integrity_managers?(contact)
    contact.is?(Role.integrity_manager)
  end

  def self.can_create?(contact)
    contact.from_ungc?
  end

  def self.can_view?(contact)
    can_create?(contact)
  end

  def can_do_due_diligence?(contact)
    self.class.from_integrity?(contact)
  end

  def can_send_to_integrity?(contact)
    (review.engagement_review? && contact.id == review.requester_id) || self.class.from_integrity?(contact)
  end

  def can_make_integrity_decision?(contact)
    self.class.from_integrity_managers?(contact)
  end

  def can_make_engagement_decision?(contact)
    contact.id == review.requester_id || self.class.from_integrity_managers?(contact)
  end

  def can_edit?(contact)
    (review.in_review? || review.local_network_review?) && can_do_due_diligence?(contact) ||
        (review.engagement_review? || review.engaged? || review.declined?) && can_make_engagement_decision?(contact) ||
        (review.integrity_review? || review.rejected?) && can_make_integrity_decision?(contact)
  end

  def can_destroy?(contact)
    self.class.can_create?(contact) &&
        review.in_review? &&
        (contact.id == review.requester_id || self.class.from_integrity?(contact))
  end
end
