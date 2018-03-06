module ActionPlatform
  class RecentSubscribers

    def initialize(platforms:, count:)
      @platforms = platforms
      @count = count
    end

    def run
      subscriptions = ActionPlatform::Subscription
        .active_at
        .includes(:platform)
        .references(:platform)
        .where(platform: @platforms)
        .order(created_at: :desc)

      Organization \
        .includes(:sector, :country, :action_platform_subscriptions)
        .references(:action_platform_subscriptions)
        .merge(subscriptions)
        .limit(@count)
    end

  end
end
