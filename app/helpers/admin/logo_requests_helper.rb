module Admin::LogoRequestsHelper
  def logo_request_actions(logo_request)
    actions = []
    actions << link_to('Back', admin_organization_path(@organization.id))
    actions.join(" | ")
  end
  
  def logo_file_image_tag(logo_file)
    # TODO we'll no longer use demo.unglobalcompact.org
    image_tag logo_file_image_url(logo_file)
  end
  
  def logo_file_image_url(logo_file)
    "http://demo.unglobalcompact.org/admin/images/gc_logos/#{logo_file.thumbnail}"
  end
  
  def comment_date(logo_comment)
    logo_comment.added_on ? logo_comment.added_on : logo_comment.created_at
  end
  
  def link_to_attached_file(logo_comment)
    if logo_comment.attachment_file_name.downcase.ends_with?('.pdf')
      file_type = 'PDF'
    elsif logo_comment.attachment_file_name.downcase.ends_with?('.doc') || 
            logo_comment.attachment_file_name.downcase.ends_with?('.docx')
      file_type = 'Word'
    else
      file_type = 'Other'
    end

    link_to "#{file_type} document", logo_comment.attachment.url, :class => "#{file_type.downcase}_doc",
                                                                  :title => "Download #{file_type} document"
  end
end
