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
          when Organization::STATE_APPROVED then OrganizationMailer.deliver_approved(comment.commentable)
          when Organization::STATE_REJECTED then OrganizationMailer.deliver_rejected(comment.commentable)
        end
      end
    end
  end
end
