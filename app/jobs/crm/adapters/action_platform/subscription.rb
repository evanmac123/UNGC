# frozen_string_literal: true

class Crm::Adapters::ActionPlatform::Subscription < Crm::Adapters::Base

  def build_crm_payload
    column('UNGC_AP_Subscription_ID__c', :id)
    column('Created_at__c', :id) { |sub| sub.created_at }
    column('Name', :organization_id) { |sub| text("#{sub.organization.name} - #{sub.platform.name}", 80) }
    column('Starts_On__c', :starts_on)
    column('Expires_On__c', :expires_on)
    column('Status__c', :state)
  end
end
