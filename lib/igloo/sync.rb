module Igloo
  class Sync

    def initialize(credentials)
      @api = Igloo::IglooApi.new(credentials)
      @file = "./tmp/igloo-sync.json"
    end

    def run(query: nil)
      @api.authenticate
      cutoff = read_last_sync_time
      query ||= IglooContactsQuery.new(cutoff)

      update_action_platform_signatories(query)
      update_staff(query)

      write_new_sync_time
    end

    private

    def update_action_platform_signatories(query)
      contacts = query.action_platform_signatories.to_a
      if contacts.any?
        puts "Updating #{contacts.count} ActionPlatform signatories"
        @api.bulk_upload(contacts)
      end
    end

    def update_staff(query)
      contacts = query.staff.to_a
      if contacts.any?
        puts "Adding #{contacts.count} staff"
        @api.bulk_upload(contacts)
      end
    end

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
      puts e
      nil
    end

  end
end
