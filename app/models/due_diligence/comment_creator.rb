module DueDiligence
  class CommentCreator
    attr_reader :comment

    def initialize(review, commenter)
      @review = review
      @commenter = commenter
      @comment = nil
    end

    def create_comment(comment_params)
      body = comment_params[:body]
      notify_participant_manager = comment_params[:notify_participant_manager] == "1"

      @comment = @review.comments.build(body: body, contact: @commenter)
      return false unless @comment.valid?

      Comment.transaction do
        @comment.save!

        event = DueDiligence::Events::CommentCreated.new(data: {
          contact_id: @commenter.id,
          body: body
          })

        stream_name = "due_diligence_review_#{@review.id}"
        EventPublisher.publish(event, to: stream_name)
      end

      @comment.persisted?.tap do |success|
        send_notifications(notify_participant_manager) if success
      end
    end

    private

    def send_notifications(notify_participant_manager = false)
      return false if @comment.nil? || @comment.errors.any?
      DueDiligenceReviewMailer.delay.comment_notifier(@comment.id) # send to integrity team by default
      # optionally send to participant manager
      DueDiligenceReviewMailer.delay.comment_notifier(@comment.id, true) if notify_participant_manager
    end

  end
end
