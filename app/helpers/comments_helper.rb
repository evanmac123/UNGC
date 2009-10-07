module CommentsHelper
  def link_to_commentable(commentable)
    link_to 'Back', commentable_path(commentable)
  end
end
