class LogoCommentObserver < ActiveRecord::Observer
  def after_create(logo_comment)
    if logo_comment.contact.from_ungc?
      case logo_comment.logo_request.state
        when LogoRequest::STATE_IN_REVIEW then LogoRequestMailer.deliver_in_review(logo_comment.logo_request)
        when LogoRequest::STATE_APPROVED then LogoRequestMailer.deliver_approved(logo_comment.logo_request)
        when LogoRequest::STATE_REJECTED then LogoRequestMailer.deliver_rejected(logo_comment.logo_request)
      end
    end
  end
end
