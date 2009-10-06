class OrganizationObserver < ActiveRecord::Observer
  def after_create(organization)
    OrganizationMailer.deliver_submission_received(organization)
  end
end
