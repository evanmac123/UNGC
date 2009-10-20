class OrganizationObserver < ActiveRecord::Observer
  def after_create(organization)
    if organization.micro_enterprise?
      OrganizationMailer.deliver_reject_microenterprise(organization)
    else
      OrganizationMailer.deliver_submission_received(organization)
    end
  end
end
