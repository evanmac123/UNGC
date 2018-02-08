# frozen_string_literal: true

module SalesforceRecordConcern
  extend ActiveSupport::Concern

  included do
    has_one  :salesforce_record, as: :rails
    delegate :record_id, :record_id=, to: :salesforce_record, allow_nil: true

    after_commit :after_create_commit, on: :create
    after_commit :after_update_commit, on: :update
    after_commit :after_destroy_commit, on: :destroy
  end

  def salesforce_id
    salesforce_record.record_id
  end

  def salesforce_record
    super || build_salesforce_record
  end

  def record_prefix
    record_id[0..2] if record_id
  end

  def record_entity
    I18n.t("salesforce.entity_prefixes.#{record_prefix}") if record_prefix
  end

  def server_id
    record_id[3..4] if record_id
  end

  def identifier
    record_id[5..17] if record_id
  end


  def after_create_commit
    after_create_update_commit('create')
  end

  def after_update_commit
    after_create_update_commit('update')
  end

  def after_destroy_commit
    return unless Rails.configuration.x_enable_crm_synchronization
    job_class.perform_later('destroy', nil, { record_id: self.record_id })
  end

  private

    def after_create_update_commit(action)
      return unless Rails.configuration.x_enable_crm_synchronization

      changes = previous_changes.except(:created_at, :updated_at)

      job_class.perform_later(action, self, changes.to_json)
    end

    def job_class
      # Organization -> Crm::OrganizationSyncJob
      "Crm::#{self.class.name}SyncJob".constantize
    end
end