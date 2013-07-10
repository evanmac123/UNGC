class LogoCommentObserver < ActiveRecord::Observer
  def after_create(logo_comment)
    if logo_comment.contact.from_ungc?
      case logo_comment.logo_request.state
        when LogoRequest::STATE_IN_REVIEW then LogoRequestMailer.in_review(logo_comment.logo_request).deliver
        when LogoRequest::STATE_APPROVED then LogoRequestMailer.approved(logo_comment.logo_request).deliver
        when LogoRequest::STATE_REJECTED then LogoRequestMailer.rejected(logo_comment.logo_request).deliver
      end
    end
  end
end
