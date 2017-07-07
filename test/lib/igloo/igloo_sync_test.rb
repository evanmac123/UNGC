require "test_helper"

module Igloo
  class SyncTest < ActiveSupport::TestCase

    test "Given two syncs, it should call upload_recent on them both" do
      credentials = {}
      api = stub("api", bulk_upload: nil, authenticate: true)
      sync = mock("sync")
      sync.expects(:upload_recent).twice
      syncs = [sync, sync]
      sync = Sync.new(credentials, api: api, syncs: syncs, log: false, track: false)
      sync.run
    end

  end
end
