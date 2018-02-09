# frozen_string_literal: true

module Crm
  class DonationSyncJob < SalesforceSyncJob

    SObjectName = 'FGC_Paypal_Payments__c'
    IdField = 'Paypal_Transaction_ID__c'
    MetadataField = 'Metadata__c'
    SObjectPrefix = '805'

    def should_sync?
      action == :create
    end

    def destroy
      # 'Donations cannot be deleted.'
    end

    def soft_delete
      # 'Donations cannot be soft deleted.'
    end
  end

end
