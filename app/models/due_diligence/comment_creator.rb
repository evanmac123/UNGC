module DueDiligence
  class CommentCreator

    def initialize(review, commenter)
      @review = review
      @commenter = commenter
      @comment = nil
    end

    def create_comment(comment_params)
      body = comment_params[:body]
      notify_participant_manager = comment_params[:notify_participant_manager] == "1"
      Comment.transaction do
        @comment = @review.comments.create!(
          body: body,
          contact: @commenter
          )

        event = DueDiligence::Events::CommentCreated.new(data: {
          contact_id: @commenter.id,
          body: body
          })

        stream_name = "due_diligence_review_#{@review.id}"
        event_store_client.publish_event(event, stream_name: stream_name)
        send_notifications(notify_participant_manager)
      end
    end

    private

    def send_notifications(notify_participant_manager = false)
      return false if @comment.nil? || @comment.errors.any?
      DueDiligenceReviewMailer.delay.comment_notifier(@comment.id) # send to integrity team by default
      # optionally send to participant manager
      DueDiligenceReviewMailer.delay.comment_notifier(@comment.id, true) if notify_participant_manager
    end

    def event_store_client
      @event_store_client ||= RailsEventStore::Client.new
    end
  end
end
