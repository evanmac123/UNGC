class Admin::DueDiligence::CommentsController < AdminController

  def create
    review = load_review
    commenter = DueDiligence::CommentCreator.new(review, current_contact)
    commenter.create_comment(comment_params)
    redirect_to admin_due_diligence_review_url(review),
      notice: t('notice.comment_created')
  end

  private

  def comment_params
    params.require(:comment).permit(:notify_participant_manager, :body)
  end

  def load_review
    ::DueDiligence::Review.find(params.fetch(:review_id))
  end

end
