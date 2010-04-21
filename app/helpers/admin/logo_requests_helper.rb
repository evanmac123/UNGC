module Admin::LogoRequestsHelper
  def comment_date(logo_comment)
    logo_comment.added_on ? logo_comment.added_on : logo_comment.created_at
  end
  
  def contact_name(logo_request_object)
    unless logo_request_object.try(:contact).try(:name)
      content_tag :span, "Contact deleted", :style => 'color: red;'
    end
  end
  
end