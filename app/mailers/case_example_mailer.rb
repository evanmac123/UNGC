class CaseExampleMailer < ActionMailer::Base
  default :from => UNGC::Application::EMAIL_SENDER

  def case_example_received(params)
    @params = OpenStruct.new params
    mail \
      :to => 'contact@unglobalcompact.org',  # TODO: Update with actual email.
      :subject => "Case Example Received from " + @params.company
  end

end
