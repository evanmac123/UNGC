class DueDiligence::Review::InReview < DueDiligence::Review::Index

  def title
    "Pending Due Diligence Research"
  end

  def path
    URI.decode(for_state_admin_due_diligence_reviews_path(state: [:in_review]))
  end
end
