class CommentNotifier
  include Sidekiq::Worker

  def perform(comment_id, notify_participant_manager = false)
    comment = Comment.find(comment_id)
    DueDiligenceReviewMailer.comment_notifier(comment, notify_participant_manager).deliver
  end

end
