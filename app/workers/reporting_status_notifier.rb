class ReportingStatusNotifier
  include Sidekiq::Worker

  def perform(mail_method, organization_id)
    org = Organization.find(organization_id)
    if org.non_business?
      send_coe_mailer(mail_method, org)
    elsif org.business?
      send_cop_mailer(mail_method, org)
    else
      "Great job you broke the internet"
    end
  end

  private

  def send_cop_mailer(mail_method, org)
    begin
      CopMailer.public_send(mail_method, org).deliver
      cop_log_success(mail_method, org)
    rescue => error
      cop_log_failure(mail_method, org, error)
      raise
    end
  end

  def send_coe_mailer(mail_method, org)
    begin
      CoeMailer.public_send(mail_method, org).deliver
      coe_log_success(mail_method, org)
    rescue => error
      coe_log_failure(mail_method, org, error)
      raise
    end
  end

  def coe_log_success(mail_method, org)
    ReportingReminderEmailStatus.create!(organization_id: org.id, success: true, reporting_type: 'coe', email: mail_method)
  end

  def coe_log_failure(mail_method, org, error)
    ReportingReminderEmailStatus.create!(organization_id: org.id, success: false, message: error, reporting_type: 'coe', email: mail_method)
  end

  def cop_log_success(mail_method, org)
    ReportingReminderEmailStatus.create!(organization_id: org.id, success: true, reporting_type: 'cop', email: mail_method)
  end

  def cop_log_failure(mail_method, org, error)
    ReportingReminderEmailStatus.create!(organization_id: org.id, success: false, message: error, reporting_type: 'cop', email: mail_method)
  end

end
