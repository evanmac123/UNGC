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

    save_documents(params[:organization])

    organization.update_attributes(params[:organization]) &&
      save_registration(params[:non_business_organization_registration]) &&
      organization.set_last_modified_by(contact)
  end

  private

    def update_contact
      organization.set_replied_to(contact) if Organization::STATE_IN_REVIEW
    end

    def update_state
      organization.state = Organization::STATE_IN_REVIEW if organization.state == Organization::STATE_PENDING_REVIEW
      organization.set_manual_delisted_status if params[:organization][:active] == '0'
    end

    def save_registration(par)
      if organization.non_business?
        organization.non_business_organization_registration.update_attributes par
      else
        true
      end
    end

    def save_documents(par)
      [:legal_status, :recommitment_letter, :withdrawal_letter].each do |type|
        organization.build_attachment(type, par[type]) if par[type]
      end
    end

end
