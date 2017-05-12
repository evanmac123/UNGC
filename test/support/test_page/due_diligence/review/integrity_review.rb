class DueDiligence::Review::IntegrityReview < DueDiligence::Review::Index

  def title
    "Integrity Decision"
  end

  def path
    URI.decode(for_state_admin_due_diligence_reviews_path(state: [:integrity_review]))
  end

end
