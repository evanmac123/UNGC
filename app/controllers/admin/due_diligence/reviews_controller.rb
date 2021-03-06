class Admin::DueDiligence::ReviewsController < AdminController

  helper Admin::CommentsHelper, Admin::DueDiligence::Helper

  before_action :no_organization_or_local_network_access
  before_action :can_view?, only: [:show, :create, :edit, :udpate, :for_state]
  before_action :load_review, only: [:show, :edit, :update, :destroy]

  def show
    @review = ::DueDiligence::Review::Presenter.new(@review)
  end

  def destroy
    @review = ::DueDiligence::Review::Presenter.new(@review)

    unless @review_policy.can_destroy?(current_contact)
      raise ActionController::MethodNotAllowed
    end
    @review.destroy!

    redirect_to for_state_admin_due_diligence_reviews_path
  end

  def new
    @review = ::DueDiligence::ReviewRequest.new
  end

  def edit
    @review = ::DueDiligence::ReviewRequest.from(@review)
  end

  def update
    @review = ::DueDiligence::ReviewRequest.from(@review)

    if @review.update(review_params)
      flash[:notice] = 'Saved'
      redirect_to for_state_admin_due_diligence_reviews_path
    else
      flash[:error] = @review.error_messages.to_sentence
      render :edit
    end
  end

  def create
    flash[:notice] = nil
    flash[:error] = nil

    @review = ::DueDiligence::ReviewRequest.new(review_params)

    if @review.create(as: current_contact)
      redirect_to for_state_admin_due_diligence_reviews_path(state: [:in_review])
    else
      flash[:error] = @review.error_messages.to_sentence
      render :new
    end
  end

  def for_state
    states = *(params[:state].blank? ? 'in_review' : params[:state])

    query_states = states == ['all'] ? ::DueDiligence::Review::ALL_STATES : states - ['all']

    @reviews = ::DueDiligence::Review.for_state(query_states)
                      .includes(:event, :requester, organization: [:country, :participant_manager])
                      .references(:event, :requester, :organization)
                      .order(order_from_params)

    @reviews = @reviews.related_to_contact(current_contact) if params[:only_mine] == '1'
    @reviews = @reviews.paginate(page: page, per_page: ::DueDiligence::Review.per_page) unless page == 'all'

    @liquid_layout = true
    i18n_key = states.include?('all') ? 'all' : states.first
    render :review_table, locals: { title: t("due_diligence.collection_titles.#{i18n_key}"), for_state: states }

  end

  protected

  def action
    params.fetch(:commit, {}).keys.first
  end

  def publish_change_event(changes=nil)
    model_changes = changes || @review.changes
    # convert { key: ["previous_value", "new_value"] } ==> { key: "new_valud" }
    changes_payload = model_changes.merge(model_changes) { |_k, val| val[1] }

    event = DueDiligence::Events::InfoAdded.new(data: {
        requester_id: current_contact.id,
        changes: changes_payload.to_h # changes_payload is a Params object, so we convert
    })

    stream_name = "due_diligence_review_#{@review.id}"
    EventPublisher.publish(event, to: stream_name)
  end

  def apply_attributes_with_nils(blank_params)
    # We want to make sure that blanks are treated as nil so that Rails Dirty can more easily
    # determine a clean list of changed attributes
    @review.attributes = nilify_hash_deep(blank_params)
  end

  def can_view?
    unless ::DueDiligence::ReviewPolicy.can_view?(current_contact)
      raise ActionController::MethodNotAllowed
    end
  end

  private

  def nilify_hash_deep(h)
    if h.blank?
      nil
    elsif h.is_a? Array
      h.map {|item| nilify_hash_deep item }
    elsif h.is_a? Hash
      h.merge(h) {|_k, val| nilify_hash_deep val }
    else
      h
    end
  end

  def load_review
    @review = ::DueDiligence::Review.find(params.fetch(:id))
    @review_policy = ::DueDiligence::ReviewPolicy.new(@review)
  end

  def review_params
    params.require(:review)
      .permit(:organization_name, :event_title, :level_of_engagement, :individual_subject, :additional_information)
      .merge(requester: current_contact)
  end

  def order_from_params
    if params[:sort_field] == 'comment'
      @order = ['comments.contact_id', params[:sort_direction] || 'DESC'].join(' ')
    else
      @order = [params[:sort_field] || 'due_diligence_reviews.updated_at', params[:sort_direction] || 'DESC'].join(' ')
    end
  end

  def page
    params[:page]
  end

end
