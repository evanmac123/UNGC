class Admin::ActionPlatform::PlatformSubscriptionsController < AdminController

  attr_reader :policy

  before_filter :no_organization_or_local_network_access
  before_filter :set_policy

  def destroy
    unless policy.can_destroy?
      raise ActionController::MethodNotAllowed
    end

    subscription, platform = load_platform_and_subscription
    if(subscription.destroy)
      flash[:notice] = 'The subscription has been removed.'
    else
    flash[:error] = 'There was an error removing the subscription.'
    end
    redirect_to admin_action_platform_platform_path(platform)
  end

  def approve
    unless policy.can_edit?
      raise ActionController::MethodNotAllowed
    end

   subscription, platform = load_platform_and_subscription
   if(subscription.approved!)
     flash[:notice] = 'Subscription approved.'
   else
     flash[:error] = 'Sorry, could not approve the subscription'
   end
   redirect_to admin_action_platform_platform_path(platform)
  end

  def revoke
    unless policy.can_edit?
      raise ActionController::MethodNotAllowed
    end

    subscription, platform = load_platform_and_subscription
    if(subscription.pending!)
    flash[:notice] = 'Subscription has been set as pending'
    else
    flash[:error] = 'Sorry, could not set the subscription as pending'
    end
    redirect_to admin_action_platform_platform_path(platform)
  end

  private
  def load_platform_and_subscription
    subscription = ::ActionPlatform::Subscription.find params[:id]
    return subscription, subscription.platform
  end

  def set_policy
    @policy = ActionPlatformPolicy.new(current_contact)
  end
end
