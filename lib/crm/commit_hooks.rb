module Crm
  class CommitHooks
    attr_reader :action

    def initialize(action)
      @action = action.to_sym
    end

    def after_commit(model)
      return unless Rails.configuration.x_enable_crm_synchronization

      Crm::SyncWorker.sync(model, action)
    end

  end
end
