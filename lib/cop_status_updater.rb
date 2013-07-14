class CopStatusUpdater
  class << self

    def log (method="info", string)
      @logger = Logger.new(File.join(Rails.root, 'log', 'cop_reminder.log'))
      @logger.send method.to_sym, "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} : #{string}"
    end

    def update_all
      move_active_organizations_to_noncommunicating
      # move_noncommunicating_organizations_to_delisted
      move_noncommunicating_companies_to_delisted
      extend_cop_date_for_noncommunicating_smes
    end

    def move_active_organizations_to_noncommunicating
      log "Running move_active_organizations_to_noncommunicating"
      organizations = Organization.businesses.participants.active.about_to_become_noncommunicating
      organizations.each { |org| org.communication_late; log "#{org.id}: #{org.name} is Non-Communicating" }
    end

    # this can be uncommented when we decide to treat Companies and SMEs the same way again

    # def move_noncommunicating_organizations_to_delisted
    #   log "Running move_noncommunicating_organizations_to_delisted"
    #   organizations = Organization.businesses.participants.active.about_to_become_delisted
    #   organizations.each do |organization|
    #     organization.delist
    #     begin
    #       CopMailer.delisting_today(organization).deliver
    #       log "Delist and email #{organization.id}:#{organization.name}"
    #     rescue
    #       log "error", "Could not email #{organization.id}:#{organization.name}"
    #     end
    #   end
    # end

    def move_noncommunicating_companies_to_delisted
      log "Running move_noncommunicating_companies_to_delisted"
      organizations = Organization.companies.participants.active.about_to_become_delisted
      organizations.each do |organization|
        organization.delist
        begin
          CopMailer.delisting_today(organization).deliver
          log "Delist and email #{organization.id}:#{organization.name}"
        rescue
          log "error", "Could not email #{organization.id}:#{organization.name}"
        end
      end
    end

    def extend_cop_date_for_noncommunicating_smes
      log "Running extend_cop_date_for_noncommunicating_smes"
      organizations = Organization.smes.participants.active.about_to_become_delisted
      organizations.each do |organization|
        organization.extend_cop_due_date_by_one_year
        begin
          CopMailer.delisting_today_sme(organization).deliver
          log "Extend and email #{organization.id}:#{organization.name}"
        rescue
          log "error", "Could not email #{organization.id}:#{organization.name}"
        end
      end
    end

  end # class << self

end # class CopStatusUpdater
