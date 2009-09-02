class OrganizationMailer < ActionMailer::Base
  def submission_received(organization)
    subject "We received your application"
    from EMAIL_SENDER
    content_type "text/html"
    # TODO send to the first point of contact, not first contact
    recipients organization.contacts.first.email
    body :organization => organization
  end
end
