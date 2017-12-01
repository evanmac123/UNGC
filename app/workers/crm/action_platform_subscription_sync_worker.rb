module Crm
  class ActionPlatformSubscriptionSyncWorker < SyncWorker

    def self.sync_class
      ActionPlatformSubscriptionSync
    end

    def model_class
      ActionPlatform::Subscription
    end

  end
end
