module Crm
  class ContactSyncWorker < SyncWorker
    def model_class
      Contact
    end

    def self.sync_class
      ContactSync
    end
  end
end
