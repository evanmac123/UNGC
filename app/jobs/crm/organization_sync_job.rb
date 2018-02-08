# frozen_string_literal: true

module Crm
  class OrganizationSyncJob < SalesforceSyncJob

    SObjectName = 'Account'
    SUngcIdName = 'UNGC_ID__c'

    def should_sync?
      model.sector_id.present? && model.organization_type_id.present?
    end

    def foreign_keys(transform_action)
      parent_record_id(model.local_network, transform_action) { |sf_id| Hash['Local_Network_Name__c', sf_id] }
    end
  end
end
