class CaseExampleMailer < ActionMailer::Base
  default :from => UNGC::Application::EMAIL_SENDER

  def case_example_received(params)
    @params = OpenStruct.new params
    mail \
      :to => 'rmteam@unglobalcompact.org',
      :subject => "Case Example Received from " + @params.company
  end

end
