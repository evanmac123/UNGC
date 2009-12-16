class CopReminder
  def notify_all
    notify_cop_due_in_90_days
    notify_cop_due_in_30_days
    notify_cop_due_today
  end
  
  def notify_cop_due_in_90_days
    notify_cop_due_on Organization.with_cop_status(:active).with_cop_due_on(90.days.from_now.to_date), :deliver_cop_due_in_90_days
    notify_cop_due_on Organization.with_cop_status(:noncommunicating).with_cop_due_on(90.days.from_now.to_date), :deliver_delisting_in_90_days
  end
  
  def notify_cop_due_in_30_days
    notify_cop_due_on Organization.with_cop_status(:active).with_cop_due_on(30.days.from_now.to_date), :deliver_cop_due_in_30_days
    notify_cop_due_on Organization.with_cop_status(:noncommunicating).with_cop_due_on(30.days.from_now.to_date), :deliver_delisting_in_30_days
  end
  
  def notify_cop_due_today
    notify_cop_due_on Organization.with_cop_status(:active).with_cop_due_on(Date.today), :deliver_cop_due_today
    notify_cop_due_on Organization.with_cop_status(:noncommunicating).with_cop_due_on(Date.today), :deliver_delisting_today
  end
  
  private
    def notify_cop_due_on(organizations, mailer)
      organizations.each { |org| CopMailer.send(mailer, org) }
    end
end