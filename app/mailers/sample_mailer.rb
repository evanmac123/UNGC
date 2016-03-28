class SampleMailer < ActionMailer::Base

  default :from => 'info@unglobalcompact.org'

  def sample(email, subject = nil)
    subject ||= 'Sample email from UNGC'
    mail(to: email, subject: subject)
  end

end
