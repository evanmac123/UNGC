module Admin::LogoRequestsHelper
  def comment_date(logo_comment)
    logo_comment.added_on ? logo_comment.added_on : logo_comment.created_at
  end
end
