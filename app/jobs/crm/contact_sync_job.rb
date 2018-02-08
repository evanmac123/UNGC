# frozen_string_literal: true

module Crm
  class ContactSyncJob < SalesforceSyncJob

    attr_reader :organization_should_sync

    SObjectName = 'Contact'
    SUngcIdName = 'UNGC_Contact_ID__c'

    def perform(action, model, changes = {}, crm = Crm::Salesforce.new)
      org = model&.organization
      @organization_should_sync = Crm::OrganizationSyncJob.perform_now(:should_sync?, org, {}, crm) if org
      super(action, model, changes, crm)
    end

    def foreign_keys(transform_action)
      parent_record_id(model.organization, transform_action) { |sf_id| Hash['AccountId', sf_id] }
    end

    def should_sync?
      organization_should_sync
    end
  end
end
