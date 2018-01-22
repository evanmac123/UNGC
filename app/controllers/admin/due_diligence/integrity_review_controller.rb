class Admin::DueDiligence::IntegrityReviewController < Admin::DueDiligence::ReviewsController

  def edit
    @review = load_review
    @review_policy = DueDiligence::ReviewPolicy.new(@review)
  end

  def update
    @review = load_review
    @review_policy = DueDiligence::ReviewPolicy.new(@review)

    unless @review_policy.can_make_integrity_decision?(current_contact)
      @review.errors[:base] = "You do not have permission to access that resource."
      raise 'Access Denied'
    end

    @review.attributes = recommendation_params

    flash[:notice] = nil
    flash[:error] = nil

    ::DueDiligence::Review.transaction do
      publish_change_event

      @review.save!

      case action
        when "approve_without_reservation"
          @review.approve!(current_contact)
          redirect_to for_state_admin_due_diligence_reviews_path(state: [:engagement_review])
        when "approve_with_reservation"
          @review.approve_with_reservation!(current_contact)
          redirect_to for_state_admin_due_diligence_reviews_path(state: [:engagement_review])
        when "reject"
          @review.reject!(current_contact)
          redirect_to for_state_admin_due_diligence_reviews_path(state: [:rejected])
        when "send_to_review"
          @review.send_to_review!(current_contact)
          redirect_to for_state_admin_due_diligence_reviews_path(state: [:in_review])
        when "save"
          flash[:notice] = 'Saved'
          redirect_to edit_admin_due_diligence_integrity_review_path(@review)
        else
          raise "Unexpected review integrity_review event: #{action}"
      end
    end

  rescue ActiveRecord::RecordInvalid, StateMachine::InvalidTransition, RuntimeError => e
    Rails.logger.error(e)
    flash[:error] = @review.errors.full_messages.to_sentence

    render :edit
  end

  private

  def load_review
    ::DueDiligence::Review.find(params.fetch(:id))
  end

  def recommendation_params
    required = params.require(:recommendations).permit(
      :integrity_explanation
    )
    apply_attributes_with_nils(required)
  end
end
