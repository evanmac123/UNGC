module ActionPlatform
  class OrderService

    def initialize(organization, financial_contact,
                   crm: nil, # TODO default to Crm::Salesforce
                   mailer: ActionPlatformMailer)
      @organization = organization
      @financial_contact = financial_contact
      @crm = crm
      @mailer = mailer
      @subscriptions = []
    end

    def subscribe(contact_id:, platform_id:)
      @subscriptions << {
        platform_id: platform_id,
        contact_id: contact_id
      }
    end

    # Creates an order for any subscriptions created by calls to #subscribe.
    # Sends notification emails and fires events after commit. See #create_order_and_subscriptions and #send_notifications if you need to separate the two operations.
    def create_order
      create_order_and_subscriptions.tap do |order|
        send_notifications_for_successful_order if order.present?
      end
    end

    # Create the order and subscriptions as part of a transaction
    # N.B. Does not send any notifcations. See #create_order for default behaviour. See #send_notifications_for_successful_order to send the notifications after the fact.
    def create_order_without_notifications
      create_order_and_subscriptions
    end

    # Send notifications that should go out on the successful completion of creating an order.
    # See #create_order for default behaviour
    def send_notifications_for_successful_order
      return if @order.nil?

      publish_subscription_created_event(@order)
      notify_rm_team(@order)
    end

    private

    def create_order_and_subscriptions
      Order.transaction do
        order = Order.create!(
          organization: @organization,
          financial_contact: @financial_contact,
        )

        @subscriptions.each do |s|
          platform_id = s.fetch(:platform_id)
          platform = ActionPlatform::Platform.find(platform_id)
          order.subscriptions.create!(
            contact_id: s.fetch(:contact_id),
            platform_id: platform_id,
            organization_id: @organization.id,
            starts_on: platform.default_starts_at,
            expires_on: platform.default_ends_at
          )
        end

        @order = order
      end
    end

    def notify_rm_team(order)
      # For now we will simply email the RM Team about the order
      @mailer.order_received(order.id).deliver_later if @mailer.present?

      # TODO notify Salesforce
      order.subscriptions.each do |subscription|
        @crm.create('ActionPlatformOrder__c', {}) if @crm.present?
      end
    end

    def publish_subscription_created_event(order)
      stream_name = "organization_#{order.organization_id}"

      order_event = DomainEvents::ActionPlatformOrderCreated.new(data: {
        order_id: order.id,
        organization_id: order.organization_id,
        platform_ids: order.subscriptions.map(&:platform_id)
      })

      EventPublisher.publish(order_event, to: stream_name)
      order.subscriptions.each do |subscription|
        subscription_event = DomainEvents::OrganizationSubscribbedToActionPlatform.new(data: {
          organization_id: subscription.organization_id,
          platform_id: subscription.platform_id,
          contact_id: subscription.contact_id,
          order_id: subscription.order_id,
        })
        EventPublisher.publish(subscription_event, to: stream_name)
      end

    end
  end
end
