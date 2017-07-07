module Igloo
  class Sync

    def initialize(credentials, syncs: nil, api: nil, log: true, track: true)
      @api = api || Igloo::IglooApi.new(credentials)
      @file = "./tmp/igloo-sync-#{Rails.env}.json"
      @child_syncs = syncs || [
        Igloo::PlatformSubscriptionSync.new(@api),
        Igloo::LocalNetworkSync.new(@api),
        Igloo::StaffSync.new(@api),
      ]
      @log = log
      @track = track
    end

    def run
      @api.authenticate
      cutoff = read_last_sync_time if @track

      @child_syncs.each do |sync|
        count = sync.upload_recent(cutoff)
        puts "Synced #{count} records to Igloo" if @log
      end

      write_new_sync_time if @track
    end

    private

    def write_new_sync_time
      File.open(@file, "w") do |file|
        time = {"last_sync_time" => Time.zone.now}
        file.write(time.to_json)
      end
    end

    def read_last_sync_time
      time = JSON.parse(File.read(@file))
      last_sync = time.fetch("last_sync_time")
      DateTime.parse(last_sync)
    rescue => e
      DateTime.new(2000, 1, 1)
    end

  end
end
