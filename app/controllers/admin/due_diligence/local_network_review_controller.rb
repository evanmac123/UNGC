class Admin::DueDiligence::LocalNetworkReviewController < Admin::DueDiligence::ReviewsController

  def edit
    @review = load_review
    @review_policy = DueDiligence::ReviewPolicy.new(@review)
  end

  def update
    @review = load_review
    @review_policy = DueDiligence::ReviewPolicy.new(@review)

    unless @review_policy.can_do_due_diligence?(current_contact)
      @review.errors[:base] = "You do not have permission to access that resource."
      raise 'Access Denied'
    end

    @review.attributes = review_params unless %w(engaged declined).include?(@review.state)

    flash[:notice] = nil
    flash[:error] = nil

    ::DueDiligence::Review.transaction do
      publish_change_event

      @review.save!

      case action
        when 'send_to_review'
          @review.send_to_review!(current_contact)
          redirect_to for_state_admin_due_diligence_reviews_path(state: [:in_review])
        when "request_integrity_review"
          @review.request_integrity_review!(current_contact)
          redirect_to for_state_admin_due_diligence_reviews_path(state: [:integrity_review])
        when "save"
          flash[:notice] = 'Saved'
          redirect_to edit_admin_due_diligence_local_network_review_path(@review)
        else
          raise "Unexpected review finalizer event: #{action}"
      end
    end

  rescue ActiveRecord::RecordInvalid, StateMachine::InvalidTransition, RuntimeError
    flash[:error] = @review.errors.full_messages.to_sentence

    render :edit
  end

  private

  def load_review
    ::DueDiligence::Review::Presenter.new(::DueDiligence::Review.find(params.fetch(:id)))
  end

  def review_params
    required = params.require(:local_network_input).permit(
      :local_network_input,
    )
    apply_attributes_with_nils(required)
  end

end
