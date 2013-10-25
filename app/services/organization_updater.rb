class OrganizationUpdater

  attr_reader :organization, :params, :contact

  def initialize(organization, contact, params)
    @organization = organization
    @contact = contact
    @params = params
  end

  def update
    organization.state = Organization::STATE_IN_REVIEW if organization.state == Organization::STATE_PENDING_REVIEW
    organization.set_replied_to(contact) if Organization::STATE_IN_REVIEW
    organization.set_manual_delisted_status if params[:organization][:active] == '0'

    save_documents(params[:organization])

    organization.update_attributes(params[:organization]) &&
      save_registration(params[:non_business_organization_registration]) &&
      organization.set_last_modified_by(contact)
  end

  private

    def save_registration(par)
      if organization.non_business?
        organization.non_business_organization_registration.update_attributes par
      else
        true
      end
    end

    def save_documents(par)
      if par[:legal_status]
        organization.build_legal_status(attachment: par[:legal_status])
        par.delete(:legal_status)
      end
      if par[:recommitment_letter]
        organization.build_recommitment_letter(attachment: par[:recommitment_letter])
        par.delete(:recommitment_letter)
      end
      if par[:withdrawal_letter]
        organization.build_withdrawal_letter(attachment: par[:withdrawal_letter])
        par.delete(:withdrawal_letter)
      end
    end
end
