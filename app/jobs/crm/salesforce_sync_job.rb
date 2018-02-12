# frozen_string_literal: true

module Crm
  class SalesforceSyncJob < ActiveJob::Base

    ALLOWED_METHODS = [:create, :update, :destroy, :synced_record_id, :should_sync?]
    attr_reader :action, :model, :model_id, :adapter, :changes, :crm

    def perform(action, model, changes = {}, crm = Crm::Salesforce.new)
      @action = action.to_sym

      @model = model
      @changes = changes.is_a?(String) ? JSON.parse(changes, symbolize_names: true) : changes

      if model
        crm_prefix = 'Crm::' unless model.class.name[0..4] == 'Crm::'
        adapter_class_name  = "#{crm_prefix}#{model.class.name}".gsub("Crm::", "Crm::Adapters::")
        @adapter = adapter_class_name.constantize.new(model, @changes)
      end

      @model_id = model&.id || @changes[:record_id]
      @crm = crm

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
      salesforce_record_id = crm.create(object_name, adapter.transformed_crm_params(:create, foreign_keys(:create)))
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
      return unless should_sync?
      salesforce_record_id = record_id
      if salesforce_record_id.blank?
        create
      else
        log("updating")
        crm.update(object_name, salesforce_record_id, adapter.transformed_crm_params(:update, foreign_keys(:update)))
        record_id
      end
    end

    def destroy
      log("deleting")
      crm.destroy(object_name, changes[:record_id]) unless changes[:record_id].blank?
    end

    def soft_delete
      log("soft deleting")
      crm.soft_delete(object_name, changes[:record_id]) if changes[:record_id]
    end

    def record_id
      salesforce_record.record_id.blank? ?
          save_record_id(find_record_id) :
          salesforce_record.record_id
    end

    def synced_record_id
      salesforce_record_id = record_id
      # create the object in Salesforce if it doesn't exist
      salesforce_record_id = create unless salesforce_record_id
      salesforce_record_id
    end

    def parent_record_id(parent_model, transform_action)
      if parent_model && (transform_action == :create || parent_model.record_id.blank?)
        job_class = "Crm::#{parent_model.class.name}SyncJob".constantize
        parent_model_record_id = job_class.perform_now(:synced_record_id, parent_model, {}, crm)
        yield(parent_model_record_id) if parent_model_record_id.present?
      end
    end

    def salesforce_record
      @salesforce_record ||= model.salesforce_record
    end

    def save_record_id(salesforce_record_id)
      if salesforce_record_id.present? && salesforce_record.record_id.blank?
        salesforce_record.record_id = salesforce_record_id
        salesforce_record.save!
      end
      salesforce_record_id
    end

    def foreign_keys(transform_action)
      {}
    end

    def find_record_id(rails_id = model_id)
      find_record(rails_id)&.Id
    end

    def find_record(rails_id = model_id)
      crm.find(object_name, rails_id.to_s, object_ungc_id_name)
    end

    protected

    def object_name
      self.class.const_get('SObjectName')
    end

    def object_ungc_id_name
      self.class.const_get('SUngcIdName')
    end

    def log(action)
      crm.log("#{action} #{object_name}-(#{model&.id}) #{model.class.name}")
    end

  end
end
