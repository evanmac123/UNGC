# frozen_string_literal: true

module Crm
  class ContactSyncJob < SalesforceSyncJob

    SObjectName = 'Contact'
    SUngcIdName = 'UNGC_Contact_ID__c'
    SObjectPrefix = '003'


    class ContactAccountIdEmpty < StandardError
      def initialize(data)
        @data = data
      end
    end

    rescue_from(ContactAccountIdEmpty) do |e|
      Rails.logger.error "ContactSyncJob delaying #{action} for #{model.id}-#{model.first_name} #{model.last_name} because its #{(model.organization || model.local_network).class.name} parent has no AccountID yet."
      if retries > 4
        raise StandardError.new("ContactSyncJob delaying #{action} for #{model.id}-#{model.first_name} #{model.last_name} because its #{(model.organization || model.local_network).class.name} could not be determined within retry count (#{retries})")
      else
        self.class.set(wait: 5.seconds).perform_later(action.to_s, model, changes.to_json, retries: retries + 1)
      end
    end

    def foreign_keys
      parent = parent_model.reload
      parent_record_id('AccountId', parent, changed?(:organization_id) || changed?(:local_network_id))
      raise ContactAccountIdEmpty.new(parent) if action == :create && foreign_key_hash.empty?
    end

    def should_sync?
      parent = parent_model
      return false if parent.nil?
      job_class = "Crm::#{parent.class.name}SyncJob".constantize
      job_class.perform_now(:should_sync?, parent, nil, crm)
    end

    def self.excluded_attributes
      [*super, :last_sign_in_at, :current_sign_in_at, :sign_in_count]
    end

    private

    def parent_model
      model.organization || model.local_network
    end

  end
end
