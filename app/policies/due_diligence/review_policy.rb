class DueDiligence::ReviewPolicy

  attr_reader :review

  def initialize(review)
    @review = review
  end

  def self.can_create?(contact)
    contact.from_ungc?
  end

  def self.can_view?(contact)
    can_create?(contact)
  end

  def can_do_due_diligence?(contact)
    contact.from_integrity_team?
  end

  def can_send_to_integrity?(contact)
    (review.engagement_review? && contact.id == review.requester_id) || contact.from_integrity_team?
  end

  def can_make_integrity_decision?(contact)
    contact.from_integrity_managers?
  end

  def can_make_engagement_decision?(contact)
    contact.id == review.requester_id || contact.from_integrity_managers?
  end

  def can_edit?(contact)
    can_edit_ongoing_review?(contact) ||
      can_edit_engagement_review?(contact) ||
      can_edit_integrity_review?(contact)
  end

  def can_destroy?(contact)
    self.class.can_create?(contact) &&
        review.in_review? &&
        (contact.id == review.requester_id || contact.from_integrity_team?)
  end

  private

  def can_edit_ongoing_review?(contact)
    in_review_state = (review.in_review? || review.local_network_review?)
    in_review_state && (can_do_due_diligence?(contact) || contact == review.requester)
  end

  def can_edit_engagement_review?(contact)
    in_engagement_state = (review.engagement_review? || review.engaged? || review.declined?)
    in_engagement_state && can_make_engagement_decision?(contact)
  end

  def can_edit_integrity_review?(contact)
    in_integrity_state = (review.integrity_review? || review.rejected?)
    in_integrity_state && can_make_integrity_decision?(contact)
  end

end
