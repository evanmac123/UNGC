class OrganizationObserver < ActiveRecord::Observer
  def after_submit(organization, transition)
    OrganizationMailer.deliver_submission_received(organization)
  end
end
