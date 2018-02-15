# Preview all emails at http://localhost:3000/rails/mailers/due_diligence_review_mailer
class DueDiligenceReviewMailerPreview < ActionMailer::Preview

  def new_review_for_research
    review = DueDiligence::Review.for_state(:in_review).first
    DueDiligenceReviewMailer.new_review_for_research(review.id, review.requester)
  end

  def new_review_for_integrity_decision
    integrity_manager = Role.integrity_manager.contacts.first
    review = DueDiligence::Review.for_state(:integrity_review).first
    DueDiligenceReviewMailer.new_review_for_integrity_decision(review.id, integrity_manager)
  end

  def integrity_decision_rendered
    review = DueDiligence::Review.for_state(:engagement_review).first
    integrity_manager = Role.integrity_manager.contacts.first
    DueDiligenceReviewMailer.integrity_decision_rendered(review.id, integrity_manager)
  end

  def engagement_decision_rendered
    review = DueDiligence::Review.for_state(:engaged).first
    DueDiligenceReviewMailer.engagement_decision_rendered(review.id, review.requester)
  end

  def comment_notifier
    DueDiligenceReviewMailer.comment_notifier(DueDiligence::Review.joins(:comments).first.comments.first.id)
  end

  def participant_manager_comment_notifier
    comment_id = DueDiligence::Review.joins(:comments).first.comments.first.id
    DueDiligenceReviewMailer.comment_notifier(comment_id, true)
  end

  private

  def organization
    @organization ||= FactoryBot.create(:organization)
  end

  def review
    @review ||= FactoryBot.create(:due_diligence_review, organization: organization)
  end

  def comment
    @comment ||= FactoryBot.create(:comment, commentable: review)
  end
 
end
