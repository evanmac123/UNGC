# frozen_string_literal: true

module Crm
  class LocalNetworkSyncJob < SalesforceSyncJob

    SObjectName = "Account"
    SUngcIdName = 'External_ID__c'
    SObjectPrefix = '001'
    SObjectRecordType = '0121H000000rHIIQA2'

    # TODO: Remove this interim lookup for the left-padded IDs until all IDs have been replaced
    def find_record_id(rails_id = model.id)
      super(adapter.class.convert_id(rails_id)) || super("LN-#{'%03d' % rails_id}")
    end

    def destroy
      soft_delete
    end
  end
end
