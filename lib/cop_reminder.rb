class CopReminder
  attr_accessor :logger, :organization_scope

  def initialize(logger = nil)
    @logger = logger || BackgroundJobLogger.new('cop_reminder.log')
    @organization_scope = Organization.businesses.participants
  end

  def notify_all
    delisting_in_9_months
    notify_cop_due_in_90_days
    notify_cop_due_in_30_days
    delisting_in_7_days
    notify_cop_due_today
    notify_cop_due_yesterday
  end

  def delisting_in_9_months
    log "Running delisting_in_9_months"
    notify :delisting_in_9_months,
      non_communicating.with_cop_due_on(9.months.from_now.to_date - 1.year)
  end

  def notify_cop_due_in_90_days
    log "Running notify_cop_due_in_90_days"
    notify :cop_due_in_90_days,
      active.with_cop_due_on(90.days.from_now.to_date)

    notify :delisting_in_90_days,
      non_communicating.with_cop_due_on(90.days.from_now.to_date - 1.year)
  end

  def notify_cop_due_in_30_days
    log "Running notify_cop_due_in_30_days"
    notify :cop_due_in_30_days,
      active.with_cop_due_on(30.days.from_now.to_date)

    notify :delisting_in_30_days,
      non_communicating.with_cop_due_on(30.days.from_now.to_date - 1.year)
  end

  def delisting_in_7_days
    log "Running delisting_in_7_days"
    notify :delisting_in_7_days,
      non_communicating.with_cop_due_on(7.days.from_now.to_date - 1.year)
  end

  def notify_cop_due_today
    log "Running notify_cop_due_today"
    notify :cop_due_today,
      active.with_cop_due_on(Date.current + 1.day)
  end

  def notify_cop_due_yesterday
    log "Running notify_cop_due_yesterday"
    notify :cop_due_yesterday,
      non_communicating.with_cop_due_on(Date.current - 1.day)
  end

  private

    def notify(mail_method, organizations)
      organizations.each do |org|
        log "Emailing organization #{org.id}:#{org.name}"
        ReportingStatusNotifier.perform_async(mail_method, org.id)
      end
    end

    def non_communicating
      organization_scope.with_cop_status(:noncommunicating)
    end

    def active
      organization_scope.with_cop_status(:active)
    end

    def log(message)
      logger.info(message)
    end

    def error(message, error)
      logger.error(message, error)
    end

end
