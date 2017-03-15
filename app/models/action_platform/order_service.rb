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

    def create_order
      create_order_and_subscriptions.tap do |order|
        publish_subscription_created_event(order)
        notify_rm_team(order)
      end
    end

    private

    def create_order_and_subscriptions
      Order.transaction do
        order = Order.create!(
          organization: @organization,
          financial_contact: @financial_contact,
        )

        # TODO don't n+1 the platform lookup
        @subscriptions.each do |s|
          platform_id = s.fetch(:platform_id)
          platform = Platform.find(platform_id)
          order.subscriptions.create!(
            contact_id: s.fetch(:contact_id),
            platform_id: platform_id,
            organization_id: @organization.id,
            expires_on: 1.year.from_now # TODO flesh out expiry rules.
          )
        end

        order
      end
    end

    def notify_rm_team(order)
      # For now we will simply email the RM Team about the order
      @mailer.delay.order_received(order.id) if @mailer.present?

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

      event_store.publish_event(order_event, stream_name: stream_name)
      order.subscriptions.each do |subscription|
        subscription_event = DomainEvents::OrganizationSubscribbedToActionPlatform.new(data: {
          organization_id: subscription.organization_id,
          platform_id: subscription.platform_id,
          contact_id: subscription.contact_id,
          order_id: subscription.order_id,
        })
        event_store.publish_event(subscription_event, stream_name: stream_name)
      end

    end

    def event_store
      RailsEventStore::Client.new
    end
  end
end
