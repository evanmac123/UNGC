class ActionPlatformMailerPreview < ActionMailer::Preview

  def order_received
    order = FactoryBot.create(:action_platform_order)
    order.subscriptions += FactoryBot.create_list(:action_platform_subscription, 3)
    ActionPlatformMailer.order_received(order.id)
  end

end
