module Igloo
  class PlatformSubscriptionQuery

    def include?(contact)
      subscriptions.active.where(contact: contact).any?
    end

    def recent(cutoff)
      tables = %w(contacts organizations sectors countries action_platform_subscriptions)
      recent_updates = tables.map { |t| "#{t}.updated_at >= ?" }.join(" or ")
      bind_params = tables.count.times.map { cutoff }

      subscriptions.
        where(recent_updates, *bind_params)
    end

    private

    def subscriptions
      ActionPlatform::Subscription.
        includes(:platform, contact: [:country, organization: [:sector]]).
        references(contact: [:country, organization: [:sector]])
    end

  end
end
