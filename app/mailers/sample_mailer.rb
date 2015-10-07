class SampleMailer < ActionMailer::Base

  default :from => UNGC::Application::EMAIL_SENDER

  def sample(email, subject = nil)
    subject ||= 'Sample email from UNGC'
    mail(to: email, subject: subject)
  end

end
