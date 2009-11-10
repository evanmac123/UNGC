module AdminHelper
  
  def path_for_polymorphic_commentable(commentable, comment)
    case commentable
    when CaseStory
      new_admin_case_story_comment_path(commentable)
    when Organization
      new_admin_organization_comment_path(commentable)
    when CommunicationOnProgress
      new_admin_communication_on_progress_comment_path(commentable)
    else
      raise "Polymorphic comment wasn't aware of #{commentable.inspect}".inspect
    end
  end
  
  def possibly_link_to_organization
    content_tag :p, "for #{link_to current_user.organization.name, edit_admin_organization_path(current_user.organization.id)} staff" if logged_in?
  end
end