module Admin::LogoRequestsHelper
  def comment_date(logo_comment)
    logo_comment.added_on ? logo_comment.added_on : logo_comment.created_at
  end

  def contact_name(logo_request)
    if logo_request.try(:contact).try(:name)
      logo_request.contact.name
    else
      content_tag :span, "Contact deleted", :style => 'color: red;'
    end
  end

  def return_to_current_list(logo_request)
    case logo_request.state
      when LogoRequest::STATE_PENDING_REVIEW
        link_to "Return to requests pending review", pending_review_admin_logo_requests_path
      when LogoRequest::STATE_IN_REVIEW
        if logo_request.replied_to
          link_to "Return to requests in review", in_review_admin_logo_requests_path
        else
          link_to "Return to updated requests", unreplied_admin_logo_requests_path
        end
      when LogoRequest::STATE_PENDING_REVIEW
        link_to "Return to #{logo_request.state} requests", pending_review_admin_logo_requests_path
      when LogoRequest::STATE_APPROVED
        link_to "Return to #{logo_request.state} requests", approved_admin_logo_requests_path
      when LogoRequest::STATE_REJECTED
        link_to "Return to #{logo_request.state} requests", rejected_admin_logo_requests_path
      when LogoRequest::STATE_ACCEPTED
        link_to "Return to #{logo_request.state} requests", accepted_admin_logo_requests_path
    end
  end
  
  def contribution_status(logo_request)
    logo_request.organization.contributor_for_year?([current_year, current_year - 1]) ? 'Contribution received' : "No contribution received for #{current_year - 1} - #{current_year}"
  end
  
  def contribution_received?(logo_request)
    if logo_request.organization.company?
      logo_request.organization.contributor_for_year?([current_year, current_year - 1]) ? '' : image_tag('unchecked.png', height: '15', width: '15')
    end
  end

end
