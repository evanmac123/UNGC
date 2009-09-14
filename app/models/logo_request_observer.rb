class LogoRequestObserver < ActiveRecord::Observer
  def after_save(logo_request)
    #TODO find out why state_machine doesn't give me a working after_in_review method
    after_in_review(logo_request, nil) if logo_request.in_review?
  end
  
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
