class DueDiligence::Review::EngagementDecision < DueDiligence::Review::Index

  def title
    "Engagement Decision"
  end

  def path
    URI.decode(for_state_admin_due_diligence_reviews_path(state: [:engagement_review]))
  end

end
