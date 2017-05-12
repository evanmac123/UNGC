class DueDiligence::Review::PendingReview < DueDiligence::Review::Index

  def title
    "Pending Review"
  end

  def path
    pending_review_admin_due_diligence_reviews_path
  end

end
