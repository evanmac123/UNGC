class Admin::DueDiligence::RiskAssessmentsController < Admin::DueDiligence::ReviewsController

  helper_method :rep_risk_rri_values

  def edit
    @review = load_risk_assessment
    @review_policy = DueDiligence::ReviewPolicy.new(@review)
  end

  def update
    @review = load_risk_assessment

    @review_policy = DueDiligence::ReviewPolicy.new(@review)
    unless @review_policy.can_do_due_diligence?(current_contact)
      @review.errors[:base] = "You do not have permission to access that resource."
      raise 'Access Denied'
    end

    @review.attributes = risk_assessment_params unless %w(engaged declined).include?(@review.state)

    flash[:notice] = nil
    flash[:error] = nil

    ::DueDiligence::Review.transaction do
      publish_change_event

      @review.save!

      case action
        when "request_integrity_review"
          @review.request_integrity_review!(current_contact)
          redirect_to for_state_admin_due_diligence_reviews_path(state: [:integrity_review])
        when "request_local_network_input"
          @review.request_local_network_input!(current_contact)
          redirect_to for_state_admin_due_diligence_reviews_path(state: [:local_network_review])
        when "save"
          flash[:notice] = 'Saved'
          redirect_to edit_admin_due_diligence_risk_assessment_path(@review)
        else
          raise "Unexpected review finalizer event: #{action}"
      end
    end

  rescue ActiveRecord::RecordInvalid, StateMachine::InvalidTransition, RuntimeError
    flash[:error] = @review.errors.full_messages.to_sentence
    render :edit
  end

  private

  def load_risk_assessment
    ::DueDiligence::Review::Presenter.new(::DueDiligence::Review.find(params.fetch(:id)))
  end

  def risk_assessment_params
    required = params.require(:review).permit(
      :world_check_allegations,
      :esg_score,
      :highest_controversy_level,
      :rep_risk_peak,
      :included_in_global_marketplace,
      :subject_to_sanctions,
      :excluded_by_norwegian_pension_fund,
      :subject_to_dialog_facilitation,
      :involved_in_landmines,
      :involved_in_tobacco,
      :local_network_input,
      :rep_risk_current,
      :rep_risk_severity_of_news,
      :requires_local_network_input,
      :additional_research,
      :analysis_comments,
    )

    apply_attributes_with_nils(required)
  end

  def rep_risk_rri_values
    # Translate the NA value with value -1
    v = [t(:na, scope: [:due_diligence, :values, :rep_risk, :score].freeze), -1]
    [v, *(0..100)]
  end

end
