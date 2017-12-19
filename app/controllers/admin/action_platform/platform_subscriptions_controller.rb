class Admin::ActionPlatform::PlatformSubscriptionsController < AdminController

  attr_reader :policy

  before_filter :no_organization_or_local_network_access
  before_filter :load_platform_and_subscription

  attr_reader :subscription, :platform, :policy

  def edit
  end

  def update
    raise ActionController::MethodNotAllowed unless policy.can_edit?(current_contact)

    subscription.attributes = subscription_params

    ::ActionPlatform::Subscription.transaction do

      subscription.save!

      action = params.fetch(:commit, {}).keys.first

      case action
        when "approve"
          subscription.approve!(current_contact)
        when "decline"
          subscription.decline!(current_contact)
        when "back_to_pending"
          subscription.back_to_pending!(current_contact)
        when "send_to_ce_review"
          subscription.send_to_ce_review!(current_contact)
        when "save"

        else
          raise "Unexpected subscription finalizer event: #{action}"
      end
      flash[:notice] = 'Saved'
    end

    redirect_to admin_action_platform_platform_path(platform)

  rescue ActiveRecord::RecordInvalid, StateMachine::InvalidTransition, RuntimeError => e
    flash[:error] = subscription.errors.full_messages.to_sentence
    render :edit
  end

  def destroy
    raise ActionController::MethodNotAllowed unless policy.can_destroy?(current_contact)

    subscription.destroy!

    flash[:notice] = 'The subscription has been removed.'
  rescue ActiveRecord::DeleteRestrictionError
    flash[:error] = @subscription.errors.full_messages
  ensure
    redirect_to admin_action_platform_platform_path(platform)
  end


  private

  def load_platform_and_subscription
    @subscription = ::ActionPlatform::Subscription.find(params[:id])
    @platform = subscription.platform
    @policy = ActionPlatform::SubscriptionPolicy.new(subscription)
  end

  def subscription_params
    params.require(:subscription).permit(
        :contact_id,
        :starts_on,
        :expires_on,
        )
  end

end
