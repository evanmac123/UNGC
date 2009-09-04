module LogoRequestsHelper
  def logo_request_actions(logo_request)
    actions = []
    actions << link_to('Back', @organization)
    actions.join(" | ")
  end
end
