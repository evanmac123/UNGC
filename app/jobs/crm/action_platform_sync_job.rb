# frozen_string_literal: true

module Crm
  class ActionPlatformSyncJob < SyncJob

    class CommitHook < SyncJob::CommitHooks
    end

  end
end
