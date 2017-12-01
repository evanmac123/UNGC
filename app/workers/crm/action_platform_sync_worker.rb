module Crm
  class ActionPlatformSyncWorker < SyncWorker

    def self.sync_class
      ActionPlatformSync
    end

    def model_class
      ActionPlatform::Platform
    end

  end
end
