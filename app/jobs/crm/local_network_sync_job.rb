# frozen_string_literal: true

module Crm
  class LocalNetworkSyncJob < SalesforceSyncJob

    SObjectName = "Local_Network__c"
    SUngcIdName = 'External_ID__c'

    def find_record_id(rails_id = model.id)
      super(adapter.class.convert_id(rails_id))
    end

    def destroy
      soft_delete
    end
  end
end
