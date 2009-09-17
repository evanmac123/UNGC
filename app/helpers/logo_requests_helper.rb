module LogoRequestsHelper
  def logo_request_actions(logo_request)
    actions = []
    actions << link_to('Back', @organization)
    actions.join(" | ")
  end
  
  def logo_file_image_tag(logo_file)
    # TODO we'll no longer use demo.unglobalcompact.org
    image_tag logo_file_image_url(logo_file)
  end
  
  def logo_file_image_url(logo_file)
    "http://demo.unglobalcompact.org/admin/images/gc_logos/#{logo_file.thumbnail}"
  end
end
