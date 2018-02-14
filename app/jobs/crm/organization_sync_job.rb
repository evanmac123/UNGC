# frozen_string_literal: true

module Crm
  class OrganizationSyncJob < SalesforceSyncJob

    SObjectName = 'Account'
    SUngcIdName = 'UNGC_ID__c'
    SObjectPrefix = '001'

    def should_sync?
      model.sector_id.present? && model.organization_type_id.present?
    end

    def foreign_keys(transform_action)
      parent_record_id(model.local_network, :create) { |sf_id| Hash['Parent_LN_Account_Id__c', sf_id] }
    end
  end
end
