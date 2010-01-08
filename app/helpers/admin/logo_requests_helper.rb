module Admin::LogoRequestsHelper
  def logo_file_image_tag(logo_file)
    image_tag logo_file_image_url(logo_file), :alt => logo_file.name
  end
  
  def comment_date(logo_comment)
    logo_comment.added_on ? logo_comment.added_on : logo_comment.created_at
  end
end
