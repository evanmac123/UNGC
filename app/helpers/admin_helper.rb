module AdminHelper
  
  def path_for_polymorphic_commentable(commentable, comment)
    case commentable
    when CaseStory
      new_admin_case_story_comment_path(commentable)
    when Organization
      new_organization_comment_path(commentable)
    when CommuncationOnProgress
      new_communication_on_progress_comment_path(commentable)
    else
      new_comment_path() # FIXME: Raise? Does this work?
    end
  end
end