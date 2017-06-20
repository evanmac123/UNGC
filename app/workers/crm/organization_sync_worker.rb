module Crm
  class OrganizationSyncWorker < SyncWorker

    def self.sync_class
      OrganizationSync
    end

    def model_class
      Organization
    end

  end
end
