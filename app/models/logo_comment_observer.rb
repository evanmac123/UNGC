class LogoCommentObserver < ActiveRecord::Observer

  def after_create(logo_comment)
    return unless logo_comment.contact.from_ungc?

    case logo_comment.logo_request.state
    when LogoRequest::STATE_IN_REVIEW
      LogoRequestMailer.delay.in_review(logo_comment.logo_request)
    when LogoRequest::STATE_APPROVED
      LogoRequestMailer.delay.approved(logo_comment.logo_request)
    when LogoRequest::STATE_REJECTED
      LogoRequestMailer.delay.rejected(logo_comment.logo_request)
    end
  end

end
