class LogoRequestObserver < ActiveRecord::Observer
  def after_approve(logo_request, transition)
    puts "logo request approved: #{logo_request.id}"
    #LogoRequestMailer.deliver_request_approved(logo_request)
  end
end
