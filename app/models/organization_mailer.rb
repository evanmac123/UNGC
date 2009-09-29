class OrganizationMailer < ActionMailer::Base
  def submission_received(organization)
    subject "We received your application"
    from EMAIL_SENDER
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email)
    body :organization => organization
  end
end
