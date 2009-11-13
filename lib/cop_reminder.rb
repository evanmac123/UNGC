class CopReminder
  def notify_all
    notify_cop_due_in_90.days
    notify_cop_due_in_30_days
    notify_cop_due_today
  end
  
  def notify_cop_due_in_90.days
    organizations = with_cop_due_on(90.days.from_now.to_date)
    organizations.each {|org| Mailer.deliver_cop_due_in_90(org) }
  end
end