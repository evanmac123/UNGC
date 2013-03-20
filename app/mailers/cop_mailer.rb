class CopMailer < ActionMailer::Base
  helper :datetime

  default :from => UNGC::Application::EMAIL_SENDER

  def confirmation_blueprint(organization, cop, user)
    @organization = organization
    @cop          = cop
    @user         = user

    mail \
      :to      => user.email_recipient,
      :from    => 'lead@unglobalcompact.org',
      :cc      => 'lead@unglobalcompact.org',
      :subject => "Global Compact LEAD - COP Status"
  end

  def confirmation_learner(organization, cop, user)
    @organization = organization
    @cop          = cop
    @user         = user

    mail \
      :to      => user.email_recipient,
      :from    => 'cop@unglobalcompact.org',
      :subject => "UN Global Compact Status - 12 Month Learner Grace Period"
  end

  def confirmation_double_learner(organization, cop, user)
    @organization = organization
    @cop          = cop
    @user         = user

    mail \
      :to      => user.email_recipient,
      :from    => 'cop@unglobalcompact.org',
      :subject => "UN Global Compact Status - Consecutive Learner COPs"
  end

  def confirmation_active(organization, cop, user)
    @organization = organization
    @cop          = cop
    @user         = user

    mail \
      :to      => user.email_recipient,
      :from    => 'cop@unglobalcompact.org',
      :subject => "UN Global Compact Status - GC Active"
  end

  def confirmation_advanced(organization, cop, user)
    @organization = organization
    @cop          = cop
    @user         = user

    mail \
      :to      => user.email_recipient,
      :from    => 'cop@unglobalcompact.org',
      :subject => "UN Global Compact Status - GC Advanced"
  end

  def confirmation_non_business(organization, cop, user)
    @organization = organization
    @cop          = cop
    @user         = user

    mail \
      :to      => user.email_recipient,
      :from    => 'cop@unglobalcompact.org',
      :subject => "UN Global Compact - COP Published"
  end

  def cop_due_in_90_days(organization)
    @organization = organization
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :cc => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => ['vkeesari@yahoo.com', 'archive@unglobalcompact.org'],
      :subject => "UN Global Compact COP Deadline - 90 Days"
  end

  def cop_due_in_30_days(organization)
    @organization = organization
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :bcc => ['vkeesari@yahoo.com', 'archive@unglobalcompact.org'],
      :subject => "UN Global Compact COP Deadline - 30 Days"
  end

  def cop_due_today(organization)
    @organization = organization
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :cc => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => ['vkeesari@yahoo.com', 'archive@unglobalcompact.org'],
      :subject => "UN Global Compact COP Deadline - Today"
  end

  def delisting_in_90_days(organization)
    @organization = organization
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :cc => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => ['vkeesari@yahoo.com', 'archive@unglobalcompact.org'],
      :subject => "UN Global Compact Expulsion in 3 months"
  end

  def delisting_in_30_days(organization)
    @organization = organization
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :cc => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => ['vkeesari@yahoo.com', 'archive@unglobalcompact.org'],
      :subject => "Urgent - UN Global Compact Expulsion in 30 days"
  end

  def delisting_today(organization)
    @organization = organization
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :cc => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => ['vkeesari@yahoo.com', 'archive@unglobalcompact.org'],
      :subject => "UN Global Compact Status - Expelled"
  end

  def delisting_today_sme(organization)
    @organization = organization
    mail \
      :to      => organization.contacts.contact_points.collect(&:email_recipient),
      :bcc     => ['vkeesari@yahoo.com', 'archive@unglobalcompact.org'],
      :subject => "UN Global Compact Status - Important - Second consecutive COP deadline missed"
  end

end
