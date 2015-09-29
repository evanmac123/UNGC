class CoeMailer < ActionMailer::Base
  helper DatetimeHelper

  default :from => UNGC::Application::EMAIL_SENDER

  def communication_on_engagement_90_days(organization)
    @organization = organization
    mail \
      to:       contact_points(organization),
      cc:       report_recipients(organization),
      bcc:      archives,
      subject:  "UN Global Compact COE Deadline - 90 days"
  end

  def communication_on_engagement_30_days(organization)
    @organization = organization
    mail \
      to:       contact_points(organization),
      cc:       report_recipients(organization),
      bcc:      archives,
      subject:  "UN Global Compact COE Deadline - 30 days"
  end

  def communication_on_engagement_1_week_before_nc(organization)
    @organization = organization
    mail \
      to:       contact_points(organization),
      cc:       report_recipients(organization),
      bcc:      archives,
      subject:  "UN Global Compact COE Deadline - 1 week"
  end

  def communication_on_engagement_due_today(organization)
    due_date = organization.cop_due_on.strftime('%e %B, %Y')
    @organization = organization
    mail \
      to:       contact_points(organization),
      cc:       report_recipients(organization),
      bcc:      archives,
      subject:  "UN Global Compact COE Deadline - #{due_date} 23:00 UTC"
  end

  def communication_on_engagement_nc_day_notification(organization)
    @organization = organization
    mail \
      to:       contact_points(organization),
      cc:       report_recipients(organization),
      bcc:      archives,
      subject:  "UN Global Compact COE Deadline - Non-Communicating COE Status"
  end

  def communication_on_engagement_1_month_after_nc(organization)
    @organization = organization
    mail \
      to:       contact_points(organization),
      cc:       report_recipients(organization),
      bcc:      archives,
      subject:  "#{@organization.name} at risk of expulsion from UN Global Compact"
  end

  def communication_on_engagement_9_months_before_expulsion(organization)
    @organization = organization
    mail \
      to:       contact_points(organization),
      cc:       report_recipients(organization),
      bcc:      archives,
      subject:  "#{@organization.name} at risk of expulsion from UN Global Compact - 9 months"
  end

  def communication_on_engagement_3_months_before_expulsion(organization)
    @organization = organization
    mail \
      to:       contact_points(organization),
      cc:       report_recipients(organization),
      bcc:      archives,
      subject:  "#{@organization.name} at risk of expulsion from UN Global Compact - 3 months"
  end

  def communication_on_engagement_1_month_before_expulsion(organization)
    @organization = organization
    mail \
      to:       contact_points(organization),
      cc:       report_recipients(organization),
      bcc:      archives,
      subject:  "#{@organization.name} at risk of expulsion from UN Global Compact - 1 months"
  end

  def communication_on_engagement_2_weeks_before_expulsion(organization)
    @organization = organization
    mail \
      to:       contact_points(organization),
      cc:       report_recipients(organization),
      bcc:      archives,
      subject:  "#{@organization.name} at risk of expulsion from UN Global Compact - 2 weeks"
  end

  def communication_on_engagement_1_week_before_expulsion(organization)
    @organization = organization
    mail \
      to:       contact_points(organization),
      cc:       report_recipients(organization),
      bcc:      archives,
      subject:  "#{@organization.name} at risk of expulsion from UN Global Compact - 1 week"
  end

  def delisting_today(organization)
    @organization = organization
    mail \
      to:       contact_points(organization),
      cc:       report_recipients(organization),
      bcc:      archives,
      :subject => "#{@organization.name} expelled from the UN Global Compact"
  end

  private

  def contact_points(organization)
    organization.contacts.contact_points.collect(&:email_recipient)
  end

  def report_recipients(organization)
    organization.network_report_recipients.collect(&:email_recipient)
  end

  def archives
    ['archive@unglobalcompact.org']
  end

end
