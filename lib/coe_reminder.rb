class CoeReminder
  attr_accessor :logger, :organization_scope

  def initialize(logger = nil)
    @logger = logger || BackgroundJobLogger.new('coe_reminder.log')
    @organization_scope = Organization.non_businesses.participants
  end

  def notify_all
    coe_due_in_90_days
    coe_due_in_30_days
    coe_due_in_1_week
    coe_due_today
    coe_due_yesterday
    coe_due_1_month_ago
    # expulsion
    expulsion_in_9_months
    expulsion_in_3_months
    expulsion_in_1_month
    expulsion_in_2_weeks
    expulsion_in_1_week
  end

  # reminder active participants of coe due date

  def coe_due_in_90_days
    log "Running coe_due_in_90_days"
    notify :communication_on_engagement_90_days,
      active.with_cop_due_on(90.days.from_now.to_date)
  end

  def coe_due_in_30_days
    log "Running coe_due_in_30_days"
    notify :communication_on_engagement_30_days,
      active.with_cop_due_on(30.days.from_now.to_date)
  end

  def coe_due_in_1_week
    log "Running coe_due_in_1_week"
    notify :communication_on_engagement_1_week_before_nc,
      active.with_cop_due_on(1.week.from_now.to_date)
  end

  def coe_due_today
    log "Running coe_due_today"
    notify :communication_on_engagement_due_today,
      active.with_cop_due_on(Date.today + 1.day)
  end

  def coe_due_yesterday
    log "Running coe_due_yesterday"
    notify :communication_on_engagement_nc_day_notification,
      active.with_cop_due_on(Date.today - 1.day)
  end

  def coe_due_1_month_ago
    log "Running coe_due_1_month_ago"
    notify :communication_on_engagement_1_month_after_nc,
      active.with_cop_due_on(Date.today - 1.month)
  end

  # expulsion of non-communicating participants

  def expulsion_in_9_months
    log "Running expulsion_in_9_months"
    notify :communication_on_engagement_9_months_before_expulsion,
      non_communicating.with_cop_due_on(9.months.from_now.to_date - 1.year)
  end

  def expulsion_in_3_months
    log "Running expulsion_in_3_months"
    notify :communication_on_engagement_3_months_before_expulsion,
      non_communicating.with_cop_due_on(90.days.from_now.to_date - 1.year)
  end

  def expulsion_in_1_month
    log "Running expulsion_in_1_month"
    notify :communication_on_engagement_1_month_before_expulsion,
      non_communicating.with_cop_due_on(30.days.from_now.to_date - 1.year)
  end

  def expulsion_in_2_weeks
    log "Running expulsion_in_2_weeks"
    notify :communication_on_engagement_2_weeks_before_expulsion,
      non_communicating.with_cop_due_on(2.weeks.from_now.to_date - 1.year)
  end

  def expulsion_in_1_week
    log "Running expulsion_in_1_week"
    notify :communication_on_engagement_1_week_before_expulsion,
      non_communicating.with_cop_due_on(1.weeks.from_now.to_date - 1.year)
  end

  private

    def notify(mail_method, organizations)
      organizations.each do |org|
        log "Emailing organization #{org.id}:#{org.name}"
        ReportingStatusNotifier.perform_async(mail_method, org.id)
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
