require_relative 'index'

class DueDiligence::Review::AllReviews < DueDiligence::Review::Index

  def title
    "All Due Diligence Reviews"
  end

  def path
    URI.decode(for_state_admin_due_diligence_reviews_path(state: [:all]))
  end
end
