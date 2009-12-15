module AdminHelper

  def path_for_polymorphic_commentables(commentable)
    case commentable
    when CaseStory
      admin_case_story_comments_path(commentable)
    when Organization
      admin_organization_comments_path(commentable.id)
    when CommunicationOnProgress
      admin_communication_on_progress_comments_path(commentable)
    else
      raise "Polymorphic comment wasn't aware of #{commentable.inspect}".inspect
    end
  end
  
  def path_for_polymorphic_commentable(commentable, comment)
    case commentable
    when CaseStory
      new_admin_case_story_comment_path(commentable)
    when Organization
      new_admin_organization_comment_path(commentable.id)
    when CommunicationOnProgress
      new_admin_communication_on_progress_comment_path(commentable)
    else
      raise "Polymorphic comment wasn't aware of #{commentable.inspect}".inspect
    end
  end
  
  def possibly_link_to_organization
    link_to 'Edit your organization', edit_admin_organization_path(current_user.organization.id) if logged_in?
  end
end