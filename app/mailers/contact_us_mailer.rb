class ContactUsMailer < ActionMailer::Base
  default :from => UNGC::Application::EMAIL_SENDER

  def contact_us_received(params)
    @params = OpenStruct.new params
    sender = @params.email
    mail \
      :to => 'contact@unglobalcompact.org',  # TODO: Update with actual email.
      :subject => "Contact Us Received from " + sender
  end

end
