class Admin::ActionPlatform::PlatformsController < AdminController
  before_filter :no_organization_or_local_network_access
  before_filter :load_platform, only: [:show, :edit, :update, :destroy]
  before_filter :load_policy, only: :create

  attr_reader :platform, :policy

  def index
    @liquid_layout = true
    @platforms = ::ActionPlatform::Platform
                .with_subscription_counts
                .where(discontinued: params[:discontinued] == '1')
                .order(updated_at: :desc)
                .paginate(page: params[:page], per_page: params[:per_page])
  end

  def show
    @liquid_layout = true

    raise ActionController::MethodNotAllowed unless policy.can_view?

    states = *(params[:state].blank? ? 'pending' : params[:state])

    query_states = if states == %w[approved]
                     'approved'
                   else
                     states == %w[all] ? ::ActionPlatform::Subscription::ALL_STATES : states - %w[all]
                   end

    subs_query = ::ActionPlatform::Subscription
                     .for_state(query_states)
                     .joins(:order, :contact, organization: [:organization_type, :participant_manager])
                     .includes(:contact, organization: [:organization_type, :participant_manager])
                     .where(platform: @platform)
                     .order("action_platform_orders.updated_at DESC")

    subs_query = subs_query.paginate(page: params[:page], per_page: params[:per_page]) unless params[:page] == 'all'

    subs_query = subs_query.related_to_contact(current_contact, true) if params[:only_mine] == '1'

    @subscriptions = subs_query
  end

  def new
    @platform = ::ActionPlatform::Platform.new
  end

  def edit
    raise ActionController::MethodNotAllowed unless policy.can_edit?
  end

  def create
    raise ActionController::MethodNotAllowed unless policy.can_create?

    @platform = ::ActionPlatform::Platform.new(platform_params)
    if platform.save
      redirect_to admin_action_platform_platforms_path, notice: 'Platform created.'
    else
      render action: :new
    end
  end

  def update
    raise ActionController::MethodNotAllowed unless policy.can_edit?

    if platform.update(platform_params)
      redirect_to admin_action_platform_platforms_path, notice: 'Platform updated.'
    else
      render action: :edit
    end
  end

  def destroy
    raise ActionController::MethodNotAllowed unless policy.can_destroy?(platform)

    if platform.destroy
      flash[:notice] = "Platform removed."
    else
      flash[:notice] = 'Sorry, there was a problem removing the platform.'
    end
    redirect_to admin_action_platform_platforms_path
  end

  private

  def load_policy
    @policy = ::ActionPlatform::PlatformPolicy.new(current_contact)
  end


  def load_platform
    load_policy
    @platform = ::ActionPlatform::Platform
                    .with_subscription_counts
                    .find(params.fetch(:id))
  end

  def platform_params
    params.require(:action_platform_platform).permit(
      :name,
      :description,
      :default_starts_at,
      :default_ends_at,
      :slug,
      :discontinued
    )
  end
end
