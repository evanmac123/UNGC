class OrganizationUpdater

  attr_reader :organization, :params, :contact

  def initialize(params)
    @params = params
  end

  def create_signatory_organization
    signings = params[:organization].delete(:signings)
    @organization = Organization.new(params[:organization])
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

    def valid?
      organization.valid?
      validate_country
      validate_sector unless organization.non_business?
      validate_listing_status if organization.business?
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
