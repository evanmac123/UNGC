# frozen_string_literal: true

module Crm
  class SyncJob < ActiveJob::Base

    def perform(action, model, changes, crm = Crm::Salesforce.new)
      @crm = crm

      changes = JSON.parse(changes)

      # Crm::ActionPlatformSyncJob => Crm::ActionPlatformSync
      class_base_name = self.class.name[/.+(?=Job)/]
      sync_class = class_base_name.constantize
      sync_instance = sync_class.new(model, changes)

      case action
        when 'create'
          sync_instance.create
        when 'update'
          sync_instance.update
        when 'destroy'
          sync_instance.destroy(changes['id'].second)
        else
          Rails.logger.error "SyncJob received unhandled action: #{action}"
      end
    end

    class CommitHooks
      attr_reader :action, :job_class

      def initialize(action)
        @action = action.to_sym

        # Crm::ActionPlatformSyncJob::CommitHooks => Crm::ActionPlatformSyncJob
        class_base_name = self.class.name[/.+(?=::)/]
        @job_class = class_base_name.constantize
      end

      def after_commit(model)
        return unless Rails.configuration.x_enable_crm_synchronization

        a_model = action == :destroy ? nil : model

        changes = model.previous_changes.except(:created_at, :updated_at)

        job_class.perform_later(action.to_s, a_model, changes.to_json)
      end
    end

  end
end
