class CopReminder
  def initialize
    @logger = Logger.new(File.join(Rails.root, 'log', 'cop_reminder.log'))
  end

  def notify_all
    delisting_in_9_months
    notify_communication_due_in_90_days
    notify_communication_due_in_30_days
    delisting_in_7_days
    notify_communication_due_today
    notify_communication_due_yesterday
  end

  def delisting_in_9_months
    log "Running delisting_in_9_months"
    notify_communication_due_on non_communicating.with_cop_due_on(9.months.from_now.to_date - 1.year), :delisting_in_9_months
  end

  def notify_communication_due_in_90_days
    log "Running notify_communication_due_in_90_days"
    notify_communication_due_on active_organizations.with_cop_due_on(90.days.from_now.to_date), :communication_due_in_90_days
    notify_communication_due_on non_communicating.with_cop_due_on(90.days.from_now.to_date - 1.year), :delisting_in_90_days
  end

  def notify_communication_due_in_30_days
    log "Running notify_communication_due_in_30_days"
    notify_communication_due_on active_organizations.with_cop_due_on(30.days.from_now.to_date), :communication_due_in_30_days
    notify_communication_due_on non_communicating.with_cop_due_on(30.days.from_now.to_date - 1.year), :delisting_in_30_days
  end

  def delisting_in_7_days
    log "Running delisting_in_7_days"
    notify_communication_due_on non_communicating.with_cop_due_on(7.days.from_now.to_date - 1.year), :delisting_in_7_days
  end

  def notify_communication_due_today
    log "Running notify_communication_due_today"
    notify_communication_due_on active_organizations.with_cop_due_on(Date.today + 1.day), :communication_due_today
  end

  def notify_communication_due_yesterday
    log "Running notify_communication_due_yesterday"
    notify_communication_due_on non_communicating.with_cop_due_on(Date.today.to_date - 1.day), :communication_due_yesterday
  end

  private
  # a separate email for Local Networks is no longer used
    def notify_communication_due_on (organizations, mailer, network_mailer = nil)
      organizations.each do |org|
        log "Emailing organization #{org.id}:#{org.name}"
        begin
          CopMailer.send(mailer, org).deliver
          if network_mailer && org.network_report_recipients.any?
            log "Emailing local network"
            CopMailer.send(network_mailer, org).deliver
          end
        rescue
          log :error, "Could not send email: #{$!}"
        end
      end
    end

    def log (method="info", string)
      @logger.send method.to_sym, "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} : #{string}"
    end

    def non_communicating
      Organization.businesses.participants.with_cop_status(:noncommunicating)
    end

    def active_organizations
      Organization.businesses.participants.with_cop_status(:active)
    end
end

