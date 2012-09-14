class CopStatusUpdater

  class << self

    def log (method="info", string)
      @logger = Logger.new(File.join(RAILS_ROOT, 'log', 'cop_reminder.log'))
      @logger.send method.to_sym, "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} : #{string}"
    end

    def update_all
      move_active_organizations_to_noncommunicating
      move_noncommunicating_organizations_to_delisted
    end

    def move_active_organizations_to_noncommunicating
      organizations = Organization.businesses.participants.active.about_to_become_noncommunicating
      organizations.each { |org| org.communication_late }
    end

    def move_noncommunicating_organizations_to_delisted
      log "Running move_noncommunicating_organizations_to_delisted"
      organizations = Organization.businesses.participants.active.about_to_become_delisted
      organizations.each do |organization|
        organization.delist
        begin
          CopMailer.deliver_delisting_today(organization)
          log "Delist and email #{organization.id}:#{organization.name}"
        rescue
          log "error", "Could not email #{organization.id}:#{organization.name}"
        end
      end
    end

  end

end
