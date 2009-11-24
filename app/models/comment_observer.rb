class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    if comment.contact.from_ungc?
      if comment.commentable.is_a? CaseStory
        case comment.commentable.state
          when CaseStory::STATE_IN_REVIEW then CaseStoryMailer.deliver_in_review(comment.commentable)
          when CaseStory::STATE_APPROVED then CaseStoryMailer.deliver_approved(comment.commentable)
          when CaseStory::STATE_REJECTED then CaseStoryMailer.deliver_rejected(comment.commentable)
        end
      elsif comment.commentable.is_a? Organization
        case comment.commentable.state
          when Organization::STATE_IN_REVIEW then OrganizationMailer.deliver_in_review(comment.commentable)
          when Organization::STATE_APPROVED then email_approved_organization(comment.commentable)
        end
      end
    end
  end
  
  private
    def email_approved_organization(organization)
      OrganizationMailer.deliver_approved(organization)
      if organization.business_entity?
        if organization.pledge_amount.to_i > 0
          OrganizationMailer.deliver_foundation_invoice(organization)
        else
          OrganizationMailer.deliver_foundation_reminder(organization)
        end
      end
    end
end
