# frozen_string_literal: true

module Crm
  class ContactSyncJob < SalesforceSyncJob

    SObjectName = 'Contact'
    SUngcIdName = 'UNGC_Contact_ID__c'
    SObjectPrefix = '003'

    def foreign_keys
      parent_organization = model.organization || model.local_network
      parent_record_id('AccountId', parent_organization, :organization_id)
    end

    def should_sync?
      parent = model.organization || model.local_network
      return false if parent.nil?
      job_class = "Crm::#{parent.class.name}SyncJob".constantize
      job_class.perform_now(:should_sync?, parent, nil, crm)
    end
  end
end
