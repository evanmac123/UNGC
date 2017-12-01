module Crm
  class LocalNetworkSyncWorker < SyncWorker

    def self.sync_class
      LocalNetworkSync
    end

    def model_class
      LocalNetwork
    end

  end
end
