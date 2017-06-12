module Igloo
  class Sync

    def initialize(credentials)
      @api = Igloo::IglooApi.new(credentials)
    end

    def run(query: nil)
      @api.authenticate
      cutoff = read_last_sync_time
      query ||= IglooContactsQuery.new(cutoff)

      update_action_platform_signatories(query)
      # update_staff(query) TODO: re-enable this

      write_new_sync_time
    end

    private

    def update_action_platform_signatories(query)
      contacts = query.action_platform_signatories
      puts "Updating #{contacts.count} ActionPlatform signatories"
      @api.bulk_upload(contacts)
    end

    def update_staff(query)
      contacts = query.staff
      puts "Adding #{contacts.count} staff"
      @api.bulk_upload(contacts)
    end

    def write_new_sync_time
      # TODO: write the current time to the filesystem
    end

    def read_last_sync_time
      # TODO: read this from the filesystem
      nil # tell the query to use it's default value
    end

  end
end
