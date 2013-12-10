class OrganizationUpdater

  attr_reader :organization, :params, :contact

  def initialize(organization, contact, params)
    @organization = organization
    @contact = contact
    @params = params
  end

  def update
    update_state
    update_contact

    organization.update_attributes(params[:organization]) &&
      save_registration(params[:non_business_organization_registration]) &&
      organization.set_last_modified_by(contact)
  end

  def error_message
    organization.error_message + organization.registration.error_message
  end

  private

    def update_contact
      organization.set_replied_to(contact) if organization.state == Organization::STATE_IN_REVIEW
    end

    def update_state
      organization.state = Organization::STATE_IN_REVIEW if organization.state == Organization::STATE_PENDING_REVIEW
      organization.set_manual_delisted_status if params[:organization][:active] == '0'
    end

    def save_registration(par)
      organization.registration.update_attributes par
    end

end
