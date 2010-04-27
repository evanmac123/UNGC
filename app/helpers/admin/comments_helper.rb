module Admin::CommentsHelper
  def link_to_commentable(commentable)
    link_to 'Cancel', commentable_path(commentable)
  end
end
