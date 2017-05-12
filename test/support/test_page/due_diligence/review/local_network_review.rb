class DueDiligence::Review::LocalNetworkReview < DueDiligence::Review::Index

  def title
    "Local Network"
  end

  def path
    URI.decode(for_state_admin_due_diligence_reviews_path(state: [:local_network_review]))
  end
end
