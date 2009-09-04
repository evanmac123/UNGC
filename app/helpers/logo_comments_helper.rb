module LogoCommentsHelper
  def comment_date(logo_comment)
    logo_comment.added_on ? logo_comment.added_on : logo_comment.created_at
  end
  
  def attachment_link(logo_comment)
    if logo_comment.attachment_file_name
      link_to logo_comment.attachment_file_name, logo_comment.attachment.url
    end
  end
end
