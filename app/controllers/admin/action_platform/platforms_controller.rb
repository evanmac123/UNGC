class Admin::ActionPlatform::PlatformsController < AdminController
  before_filter :no_organization_or_local_network_access
  before_filter :set_policy

  attr_reader :policy

  def index
    @platforms = ::ActionPlatform::Platform
                     .with_subscription_counts
                     .order(updated_at: :desc)
  end

  def show
    @platform = load_platform
    @liquid_layout = true

    unless policy.can_view?
      raise ActionController::MethodNotAllowed
    end

    @subscriptions = ::ActionPlatform::Subscription.
    includes(:platform, :contact, organization: [:organization_type]).
    joins(:order).
    where(platform: @platform).
    order("action_platform_orders.updated_at DESC")
  end

  def new
    @platform = ::ActionPlatform::Platform.new
  end

  def edit
    unless policy.can_edit?
      raise ActionController::MethodNotAllowed
    end
    @platform = load_platform
  end

  def create
    unless policy.can_create?
      raise ActionController::MethodNotAllowed
    end
    @platform = ::ActionPlatform::Platform.new(platform_params)
    if @platform.save
      redirect_to admin_action_platform_platforms_path, notice: 'Platform created.'
    else
      render action: :new
    end
  end

  def update
    unless policy.can_edit?
      raise ActionController::MethodNotAllowed
    end
    @platform = load_platform
    if @platform.update(platform_params)
      redirect_to admin_action_platform_platforms_path, notice: 'Platform updated.'
    else
      render action: :edit
    end
  end

  def destroy
    platform = load_platform
    unless policy.can_destroy?
      raise ActionController::MethodNotAllowed
    end
    if platform.destroy
      flash[:notice] = "Platform removed."
    else
      flash[:notice] = 'Sorry, there was a problem removing the platform.'
    end
    redirect_to admin_action_platform_platforms_path
  end

  private

  def load_platform
    @platform = ::ActionPlatform::Platform.find(params.fetch(:id))
  end

  def platform_params
    params.require(:action_platform_platform).permit(
      :name,
      :description,
      :slug,
      :discontinued
    )
  end

  def set_policy
    @policy = ActionPlatformPolicy.new(current_contact)
  end

end
