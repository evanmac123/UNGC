class CopMailer < ActionMailer::Base
  helper DatetimeHelper

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

  def confirmation_triple_learner_for_one_year(organization, cop, user)
    @organization = organization
    @cop          = cop
    @user         = user

    mail \
      :to      => user.email_recipient,
      :cc      => organization.participant_manager_email,
      :from    => 'cop@unglobalcompact.org',
      :subject => "UN Global Compact Status - Non-Communicating due to exceeded Learner Grace Period"
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
      :subject => "UN Global Compact - COE Published"
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
      :cc => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => ['vkeesari@yahoo.com', 'archive@unglobalcompact.org'],
      :subject => "UN Global Compact COP Deadline - 30 Days"
  end

  def cop_due_today(organization)
    @organization = organization
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :cc => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => ['vkeesari@yahoo.com', 'archive@unglobalcompact.org'],
      :subject => "UN Global Compact COP Deadline - #{@organization.cop_due_on.strftime('%e %B, %Y')} 23:00 UTC"
  end

  def delisting_in_90_days(organization)
    @organization = organization
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :cc => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => ['vkeesari@yahoo.com', 'archive@unglobalcompact.org'],
      :subject => "#{@organization.name} at risk of expulsion from UN Global Compact - 3 months"
  end

  def delisting_in_30_days(organization)
    @organization = organization
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :cc => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => ['vkeesari@yahoo.com', 'archive@unglobalcompact.org'],
      :subject => "#{@organization.name} at risk of expulsion from UN Global Compact - 1 month"
  end

  def delisting_today(organization)
    @organization = organization
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :cc => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => ['vkeesari@yahoo.com', 'archive@unglobalcompact.org'],
      :subject => "#{@organization.name} expelled from the UN Global Compact"
  end

  def delisting_today_sme(organization)
    @organization = organization
    mail \
      :to      => organization.contacts.contact_points.collect(&:email_recipient),
      :cc      => organization.network_report_recipients.collect(&:email_recipient),
      :bcc     => ['vkeesari@yahoo.com', 'archive@unglobalcompact.org'],
      :subject => "UN Global Compact Status - Important - Second consecutive COP deadline missed"
  end

  def delisting_today_sme_final(organization)
    @organization = organization
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :cc => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => ['vkeesari@yahoo.com', 'archive@unglobalcompact.org'],
      :subject => "#{@organization.name} was expelled from the UN Global Compact"
  end

end
