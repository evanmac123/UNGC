class CopReminder
  def notify_all
    notify_cop_due_in_90_days
    notify_cop_due_in_30_days
    notify_cop_due_today
  end
  
  def notify_cop_due_in_90_days
    notify_cop_due_on Organization.businesses.participants.with_cop_status(:active).with_cop_due_on(90.days.from_now.to_date),
                      :deliver_cop_due_in_90_days, :deliver_cop_due_in_90_days_notify_network

    notify_cop_due_on Organization.businesses.participants.with_cop_status(:noncommunicating).with_cop_due_on(90.days.from_now.to_date),
                      :deliver_delisting_in_90_days
  end
  
  def notify_cop_due_in_30_days
    notify_cop_due_on Organization.businesses.participants.with_cop_status(:active).with_cop_due_on(30.days.from_now.to_date),
                      :deliver_cop_due_in_30_days, :deliver_cop_due_in_30_days_notify_network

    notify_cop_due_on Organization.businesses.participants.with_cop_status(:noncommunicating).with_cop_due_on(30.days.from_now.to_date),
                      :deliver_delisting_in_30_days
  end
  
  def notify_cop_due_today
    notify_cop_due_on Organization.businesses.participants.with_cop_status(:active).with_cop_due_on(Date.today),
                      :deliver_cop_due_today, :deliver_cop_due_today_notify_network

    notify_cop_due_on Organization.businesses.participants.with_cop_status(:noncommunicating).with_cop_due_on(Date.today),
                      :deliver_delisting_today, :deliver_delisting_today_notify_network
  end
  
  private

  def notify_cop_due_on(organizations, mailer, *network_mailer)
    organizations.each do |org|
      CopMailer.send(mailer, org)
      if network_mailer && org.network_report_recipients.count > 0
        CopMailer.send(network_mailer, org)
      end      
    end
  end

end