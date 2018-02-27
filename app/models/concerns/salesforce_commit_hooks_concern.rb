# frozen_string_literal: true

module SalesforceCommitHooksConcern
  extend ActiveSupport::Concern

  included do
    after_commit :after_create_commit, on: :create
    after_commit :after_update_commit, on: :update
    after_commit :after_destroy_commit, on: :destroy
  end

  def after_create_commit
    after_create_update_commit('create')
  end

  def after_update_commit
    after_create_update_commit('update')
  end

  def after_destroy_commit
    return unless Rails.configuration.x_enable_crm_synchronization
    job_class.perform_later('destroy', nil, { record_id: [self.record_id, nil] }.to_json)
  end

  private

    def after_create_update_commit(action)
      return unless Rails.configuration.x_enable_crm_synchronization

      changes = previous_changes.except(*job_class.excluded_attributes)

      # We have to serialize because ActiveJob cannot serialize a Time object
      job_class.perform_later(action, self, changes.to_json) if changes.any?
    end

    def job_class
      # Organization -> Crm::OrganizationSyncJob
      "Crm::#{self.class.name}SyncJob".constantize
    end
end