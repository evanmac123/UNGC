# frozen_string_literal: true

class Crm::ActionPlatform::SubscriptionSyncJob < Crm::SalesforceSyncJob

  SObjectName = 'Action_Platform_Subscription__c'
  SUngcIdName = 'UNGC_AP_Subscription_ID__c'
  SObjectPrefix = '00x'

  def foreign_keys
    # Sync parents first...
    parent_record_id('Action_Platform__c', model.platform, changed?(:platform_id))
    parent_record_id('Organization__c', model.organization, changed?(:organization_id))
    # Then Children of parents
    parent_record_id('Contact_Point__c', model.contact, changed?(:contact_id))
  end
end
