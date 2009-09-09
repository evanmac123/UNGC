class LogoRequestObserver < ActiveRecord::Observer
  def after_in_review(logo_request, transition)
    LogoRequestMailer.deliver_in_review(logo_request)
  end
  
  def after_approve(logo_request, transition)
    LogoRequestMailer.deliver_approved(logo_request)
  end
  
  def after_reject(logo_request, transition)
    LogoRequestMailer.deliver_rejected(logo_request)
  end
end
