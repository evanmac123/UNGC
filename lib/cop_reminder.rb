class CopReminder
  def initialize
    @logger = Logger.new(File.join(RAILS_ROOT, 'log', 'cop_reminder.log'), 'daily')
  end
  
  def notify_all
    notify_cop_due_in_90_days
    notify_cop_due_in_30_days
    notify_cop_due_today
  end
  
  def notify_cop_due_in_90_days
    log "Running notify_cop_due_in_90_days"
    notify_cop_due_on Organization.businesses.participants.with_cop_status(:active).with_cop_due_on(90.days.from_now.to_date),
                      :deliver_cop_due_in_90_days, :deliver_cop_due_in_90_days_notify_network

    notify_cop_due_on Organization.businesses.participants.with_cop_status(:noncommunicating).with_cop_due_on(90.days.from_now.to_date),
                      :deliver_delisting_in_90_days
  end
  
  def notify_cop_due_in_30_days
    log "Running notify_cop_due_in_30_days"
    notify_cop_due_on Organization.businesses.participants.with_cop_status(:active).with_cop_due_on(30.days.from_now.to_date),
                      :deliver_cop_due_in_30_days

    notify_cop_due_on Organization.businesses.participants.with_cop_status(:noncommunicating).with_cop_due_on(30.days.from_now.to_date),
                      :deliver_delisting_in_30_days, :deliver_delisting_in_30_days_notify_network
  end
  
  def notify_cop_due_today
    log "Running notify_cop_due_today"
    notify_cop_due_on Organization.businesses.participants.with_cop_status(:active).with_cop_due_on(Date.today),
                      :deliver_cop_due_today, :deliver_cop_due_today_notify_network

    notify_cop_due_on Organization.businesses.participants.with_cop_status(:noncommunicating).with_cop_due_on(Date.today),
                      :deliver_delisting_today, :deliver_delisting_today_notify_network
  end
  
  private
    def notify_cop_due_on(organizations, mailer, network_mailer = nil)
      organizations.each do |org|
        log "Emailing organization #{org.id}:#{org.name}"
        CopMailer.send(mailer, org)
        if network_mailer and org.network_report_recipients.count > 0
          CopMailer.send(network_mailer, org)
        end
      end
    end
    
    def log(string)
      @logger.info "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} : #{string}"
    end
end