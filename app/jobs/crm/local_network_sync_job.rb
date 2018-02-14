# frozen_string_literal: true

module Crm
  class LocalNetworkSyncJob < SalesforceSyncJob

    SObjectName = "Account"
    SUngcIdName = 'External_ID__c'
    SObjectPrefix = '001'
    SObjectRecordType = '0121H000000rHIIQA2'

    def destroy
      soft_delete
    end
  end
end
