class OrganizationUpdater

  attr_reader :organization, :organization_params, :registration_params, :contact

  def initialize(organization_params, registration_params)
    @organization_params = organization_params.except('parent_company_name')
    @registration_params = registration_params
  end

  def create_signatory_organization
    signings = organization_params.delete(:signings)
    @organization = Organization.new(organization_params)
    organization.set_non_participant_fields

    if valid? && organization.save
      # XXX this seems to be optional
      organization.signings.create!(signings)
      return true
    end

    false
  end

  def update(organization, contact)
    @organization = organization
    @contact = contact

    return false unless valid?

    update_state
    update_contact

    registration = organization.registration
    organization.attributes = organization_params
    registration.attributes = registration_params

    organization.last_modified_by_id = contact.id
    organization.save && registration.save
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
      organization.set_manual_delisted_status if organization_params[:cop_state] == Organization::COP_STATE_DELISTED
    end

    def save_registration(par)
      organization.registration.update_attributes par
    end

    def valid?
      organization.valid?
      validate_sector unless organization.non_business?
      validate_listing_status if organization.business?
      validate_country
      return true unless organization.errors.any?
    end

    def validate_country
      return true if organization.country.present?
      organization.errors.add :country_id, "can't be blank"
    end

    def validate_sector
      return true if organization.sector.present?
      organization.errors.add :sector_id, "can't be blank"
    end

    def validate_listing_status
      return if organization.listing_status.present?
      organization.errors.add :listing_status_id, "can't be blank"
    end

end
