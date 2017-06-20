module Crm
  class CommitHooks
    cattr_accessor :run_in_tests

    attr_reader :action

    def initialize(action)
      @action = action.to_sym
    end

    def after_commit(model)
      return if Rails.env.test? && !self.class.run_in_tests

      Crm::SyncWorker.sync(model, action)
    end

  end
end
