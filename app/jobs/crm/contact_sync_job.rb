# frozen_string_literal: true

module Crm
  class ContactSyncJob < SalesforceSyncJob

    attr_reader :organization_should_sync, :local_network_should_sync

    SObjectName = 'Contact'
    SUngcIdName = 'UNGC_Contact_ID__c'
    SObjectPrefix = '003'

    def perform(action, model, changes = {}, crm = Crm::Salesforce.new)
      org = model&.organization
      @organization_should_sync = Crm::OrganizationSyncJob.perform_now(:should_sync?, org, {}, crm) if org
      local_network = model&.local_network
      @local_network_should_sync =  Crm::LocalNetworkSyncJob.perform_now(:should_sync?, local_network, {}, crm) if local_network
      super(action, model, changes, crm)
    end

    def foreign_keys(transform_action)
      parent_organization = model.organization || model.local_network
      parent_record_id(parent_organization, :create) { |sf_id| Hash['AccountId', sf_id] }
    end

    def should_sync?
      organization_should_sync || local_network_should_sync
    end
  end
end
