class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    if comment.contact.from_ungc?
      if comment.commentable.is_a? CaseStory
        case comment.commentable.state
          when CaseStory::STATE_IN_REVIEW then CaseStoryMailer.in_review(comment.commentable).deliver
          when CaseStory::STATE_APPROVED then CaseStoryMailer.approved(comment.commentable).deliver
          when CaseStory::STATE_REJECTED then CaseStoryMailer.rejected(comment.commentable).deliver
        end
      elsif comment.commentable.is_a? Organization
        case comment.commentable.state
          when Organization::STATE_IN_REVIEW then email_in_review_organization(comment)
          when Organization::STATE_NETWORK_REVIEW then OrganizationMailer.network_review(comment.commentable).deliver
          when Organization::STATE_REJECTED then email_rejected_organization(comment)
          when Organization::STATE_APPROVED then email_approved_organization(comment.commentable)
        end
      end
    end
  end

  private

    def email_rejected_organization(comment)
      organization = comment.commentable

      # only email rejection notice for micro enterprise applications
      if comment.state_event == Organization::EVENT_REJECT_MICRO
        OrganizationMailer.reject_microenterprise(organization).deliver

        if organization.network_report_recipients.count > 0
          OrganizationMailer.reject_microenterprise_network(organization).deliver
        end

      end

      # kept the original names in the email
      organization.set_rejected_names
    end

    def email_in_review_organization(comment)
      organization = comment.commentable
      OrganizationMailer.in_review(organization).deliver
      # checkbox was selected
      if comment.copy_local_network? && organization.network_report_recipients.count > 0
        OrganizationMailer.in_review_local_network(organization).deliver
      end
    end

    def email_approved_organization(organization)
      if organization.business_entity?
        OrganizationMailer.approved_business(organization).deliver
      else
        OrganizationMailer.approved_nonbusiness(organization).deliver
      end

      if organization.network_report_recipients.count > 0
        OrganizationMailer.approved_local_network(organization).deliver
      end

      if organization.city?
        OrganizationMailer.approved_city(organization).deliver
      end

    end
end
