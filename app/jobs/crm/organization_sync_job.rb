# frozen_string_literal: true

module Crm
  class OrganizationSyncJob < SalesforceSyncJob

    SObjectName = 'Account'
    SUngcIdName = 'UNGC_ID__c'
    SObjectPrefix = '001'

    def should_sync?
      model.organization_type_id.present?
    end

    def foreign_keys
      parent_record_id('Parent_LN_Account_Id__c', model.local_network, :local_network_id)
    end
  end
end
