class Admin::DueDiligence::FinalDecisionsController < Admin::DueDiligence::ReviewsController

  def edit
    @review = load_review
    @review_policy = DueDiligence::ReviewPolicy.new(@review)
  end

  def update
    @review = load_review
    @review_policy = DueDiligence::ReviewPolicy.new(@review)

    unless @review_policy.can_make_engagement_decision?(current_contact)
      @review.errors[:base] = "You do not have permission to access that resource."
      raise 'Access Denied'
    end

    @review.attributes = final_decision_params unless %w(rejected engaged declined).include?(@review.state)

    flash[:notice] = nil
    flash[:error] = nil

    ::DueDiligence::Review.transaction do
      publish_change_event

      @review.save!

      case action
        when "engage"
          @review.engage!(current_contact)
          redirect_to for_state_admin_due_diligence_reviews_path(state: [:engaged])
        when "decline"
          @review.decline!(current_contact)
          redirect_to for_state_admin_due_diligence_reviews_path(state: [:declined])
        when "integrity_review"
          @review.request_integrity_review!(current_contact)
          redirect_to for_state_admin_due_diligence_reviews_path(state: [:integrity_review])
        when "engagement_decision"
          @review.revert_to_engagement_decision!(current_contact)
          redirect_to for_state_admin_due_diligence_reviews_path(state: [:engagement_decision])
        when "save"
          flash[:notice] = 'Saved'
          redirect_to edit_admin_due_diligence_final_decision_path(@review)
        else
          raise "Unexpected review finalizer event: #{action}"
      end
    end

    rescue ActiveRecord::RecordInvalid, StateMachine::InvalidTransition, RuntimeError
      flash[:error] = @review.errors.full_messages.to_sentence

      render :edit
  end

  private

  def final_decision_params
    required = params.require(:final_decision).permit(
      :engagement_rationale,
      :approving_chief,
      :reason_for_decline,
    )

    apply_attributes_with_nils(required)
  end

  def load_review
    ::DueDiligence::Review.find(params.fetch(:id))
  end
end
