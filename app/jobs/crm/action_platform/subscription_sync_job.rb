# frozen_string_literal: true

class Crm::ActionPlatform::SubscriptionSyncJob < Crm::SalesforceSyncJob

  SObjectName = 'Action_Platform_Subscription__c'
  SUngcIdName = 'UNGC_AP_Subscription_ID__c'
  SObjectPrefix = '00x'

  def should_sync?
    model.approved?
  end

  def foreign_keys(transform_action)
    result = {}

    # Sync parents first...
    parent_record_id(model.platform, transform_action) { |sf_id| result['Action_Platform__c'] = sf_id }
    parent_record_id(model.organization, transform_action) { |sf_id| result['Organization__c'] = sf_id }
    # Then Children of parents
    parent_record_id(model.contact, transform_action) { |sf_id| result['Contact_Point__c'] = sf_id }

    result
  end
end
