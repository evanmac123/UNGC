module CommentsHelper
  def link_to_commentable(commentable)
    link_to 'Back', commentable_path(commentable)
  end
  
  def commentable_path(commentable)
    commentable.is_a?(Organization) ? commentable : [commentable.organization, commentable]
  end
end
