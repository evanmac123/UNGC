class ActionPlatformMailer < ActionMailer::Base
  default :from => UNGC::Application::EMAIL_SENDER

  def order_received(order_id)
    @order = ActionPlatform::Order \
              .includes(:organization, subscriptions: [:platform, :contact])
              .find(order_id)

    mail \
      to: 'rmteam@unglobalcompact.org',
      subject: "Action Platform Order Received from #{@order.organization.name}"
  end

end
