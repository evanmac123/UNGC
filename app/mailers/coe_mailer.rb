class CoeMailer < ActionMailer::Base
  default :from => UNGC::Application::EMAIL_SENDER

  def example(organization, cop, user)
    @organization = organization
    @cop          = cop
    @user         = user

    mail(to: user.email_recipient, subject: 'example')
  end

end
