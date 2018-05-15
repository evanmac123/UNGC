# frozen_string_literal: true

module Crm
  class SalesforceSyncJob < ActiveJob::Base

    ALLOWED_METHODS = [:create, :update, :destroy, :synced_record_id, :should_sync?]
    attr_reader :action, :model, :model_id, :adapter, :changes, :crm, :foreign_key_hash

    def self.resync(model)
      changes = model.attributes.except(*self.excluded_attributes)
      # HACK a fake change set
      changes.transform_values! do |value|
        [nil, value]
      end
      perform_later("create", model, changes.to_json)
    end

    def perform(action, model, changes = nil, crm = Crm::Salesforce.new)
      @action = action.to_sym

      @model = model
      @changes = converted_changes(changes)

      @model_id = model&.id
      @crm = crm
      @foreign_key_hash = {}

      if ALLOWED_METHODS.include?(@action)
        send(@action)
      else
        Rails.logger.error "SalesfroceSyncJob received unhandled action: #{action}"
      end
    end

    def should_sync?
      true
    end

    def create
      return unless should_sync?
      log("creating")
      adapter = adapter_class.new(model, :create, changes)
      foreign_keys
      salesforce_record_id = crm.create(object_name, adapter.crm_payload(foreign_key_hash))
      save_record_id(salesforce_record_id)
    rescue Faraday::ClientError => e
      duplicate_pattern = /duplicate value found: .* on record with id: (\w+)/
      matches = duplicate_pattern.match(e.to_s)

      if matches
        # this is a concurrency error, the record has been created since we checked
        # try again as an update
        salesforce_record_id = matches[1]
        save_record_id(salesforce_record_id)
        update
      else
        # Not sure what this is, raise it again
        raise e
      end
    end

    def update
      return unless should_sync? && changes.any?

      salesforce_record_id = record_id
      if salesforce_record_id.blank?
        @action = :create
        create
      else
        log("updating")
        adapter = adapter_class.new(model, :update, changes)
        foreign_keys
        crm.update(object_name, salesforce_record_id, adapter.crm_payload(foreign_key_hash))
        record_id
      end
    end

    def destroy
      log("deleting")
      crm.destroy(object_name, changed_from_value(:record_id)) unless changes[:record_id].blank?
    end

    def soft_delete
      log("soft deleting")
      crm.soft_delete(object_name, changed_from_value(:record_id)) if changes[:record_id]
    end

    def record_id
      salesforce_record.record_id.blank? ?
          save_record_id(find_record_id) :
          salesforce_record.record_id
    end

    def synced_record_id
      record_id || create
    end

    def parent_record_id(salesforce_key, parent_model, parent_attribute)
      return if parent_model.nil?

      parent_model_record_id = parent_model.record_id
      if parent_model_record_id.nil?
        job_class = "Crm::#{parent_model.class.name}SyncJob".constantize
        parent_model_record_id = job_class.perform_now(:synced_record_id, parent_model, nil, crm)
        foreign_key_hash[salesforce_key] = parent_model_record_id if parent_model_record_id.present?
      elsif changed?(parent_attribute) && parent_model_record_id.present?
        foreign_key_hash[salesforce_key] = parent_model_record_id
      end
    end

    def self.excluded_attributes
      [:created_at, :updated_at]
    end

    def salesforce_record
      @salesforce_record ||= model.salesforce_record
    end

    def save_record_id(salesforce_record_id)
      if salesforce_record_id.present? && salesforce_record.record_id.blank?
        salesforce_record.record_id = salesforce_record_id
        salesforce_record.save! if salesforce_record.valid? # This should check for uniqueness
      end
      salesforce_record_id
    end

    def foreign_keys
      {}
    end

    def find_record_id(rails_id = model_id)
      converted_rails_id = adapter_class.convert_id(rails_id)
      find_record(converted_rails_id)&.Id
    end

    def find_record(rails_id = model_id)
      crm.find(object_name, rails_id.to_s, object_ungc_id_name)
    end

    protected

    def changed?(attribute)
      action == :create || (changes[attribute] && changes[attribute][0] != changes[attribute][1])
    end

    def changed_from_value(attribute)
      changes[attribute][0]
    end

    def changed_to_value(attribute)
      changes[attribute][1]
    end

    def object_name
      self.class.const_get('SObjectName')
    end

    def object_ungc_id_name
      self.class.const_get('SUngcIdName')
    end

    def log(action)
      crm.log("#{action} #{object_name}-(#{model&.id}) #{model.class.name}")
    end

    def adapter_class
      @_adapter_class ||= begin
        crm_prefix = 'Crm::' unless model.class.name[0..4] == 'Crm::'
        adapter_class_name  = "#{crm_prefix}#{model.class.name}".gsub("Crm::", "Crm::Adapters::")
        @_adapter_class = adapter_class_name.constantize
      end

    end

    private

      def converted_changes(raw_changes)
        hash_changes = raw_changes || {}
        return hash_changes if hash_changes.is_a?(Hash)
        JSON.parse(hash_changes , symbolize_names: true)
      end
  end
end
