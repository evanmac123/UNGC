class CopReminder
  def initialize
    @logger = Logger.new(File.join(Rails.root, 'log', 'cop_reminder.log'))
  end

  def notify_all
    notify_cop_due_in_90_days
    notify_cop_due_in_30_days
    notify_cop_due_today
    notify_cop_due_yesterday
  end

  def notify_cop_due_in_90_days
    log "Running notify_cop_due_in_90_days"
    notify_cop_due_on Organization.businesses.participants.with_cop_status(:active).with_cop_due_on(90.days.from_now.to_date), :cop_due_in_90_days
    notify_cop_due_on Organization.businesses.participants.with_cop_status(:noncommunicating).with_cop_due_on(90.days.from_now.to_date - 1.year), :delisting_in_90_days
  end

  def notify_cop_due_in_30_days
    log "Running notify_cop_due_in_30_days"
    notify_cop_due_on Organization.businesses.participants.with_cop_status(:active).with_cop_due_on(30.days.from_now.to_date), :cop_due_in_30_days
    notify_cop_due_on Organization.businesses.participants.with_cop_status(:noncommunicating).with_cop_due_on(30.days.from_now.to_date - 1.year), :delisting_in_30_days
  end

  def notify_cop_due_today
    log "Running notify_cop_due_today"
    notify_cop_due_on Organization.businesses.participants.with_cop_status(:active).with_cop_due_on(Date.today), :cop_due_today
  end
  
  def notify_cop_due_yesterday
    log "Running notify_cop_due_yesterday"
    notify_cop_due_on Organization.businesses.participants.with_cop_status(:noncommunicating).with_cop_due_on(Date.today.to_date - 1.day), :cop_due_yesterday
  end
  
  private
  # a separate email for Local Networks is no longer used
    def notify_cop_due_on (organizations, mailer, network_mailer = nil)
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
end

