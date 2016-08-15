module Admin::CommentsHelper
  def link_to_commentable(commentable)
    link_to 'Cancel', commentable_path(commentable)
  end

  def path_for_polymorphic_commentables(commentable)
    case commentable
    when Organization
      admin_organization_comments_path(commentable.id)
    when CommunicationOnProgress
      admin_communication_on_progress_comments_path(commentable)
    else
      raise "Polymorphic comment wasn't aware of #{commentable.inspect}".inspect
    end
  end
end
