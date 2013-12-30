class OrganizationSignup
  attr_reader :organization
  attr_reader :primary_contact, :ceo

  def initialize
    @organization = Organization.new
    @primary_contact = Contact.new_contact_point
    post_initialize
  end

  def post_initialize
  end

  def types
    raise NotImplementedError
  end

  def set_organization_attributes(par)
    organization.attributes = par[:organization]
    primary_contact.country_id = organization.country_id
  end

  def valid?
    valid_organization?
  end

  def complete_valid?
    complete_valid_organization?
  end

  def valid_organization?
    organization.valid?
    validate_country
    validate_type
    local_valid_organization?
    !organization.errors.any?
  end

  def complete_valid_organization?
    organization.valid?
    if !organization.commitment_letter?
      organization.errors.add :commitment_letter, "must be uploaded"
    end
    local_valid_organization?
    !organization.errors.any?
  end

  def local_valid_organization?
  end

  def pledge_complete?
    if organization.pledge_amount.to_i == 0 && organization.no_pledge_reason.blank?
      organization.errors.add :no_pledge_reason, "must be selected"
      return false
    else
      return true
    end
  end

  def set_primary_contact_attributes(par)
    primary_contact.attributes = par
  end

  def valid_primary_contact?
    primary_contact.valid?
  end

  def prepare_ceo
    # ceo contact fields which default to contact
    ceo.phone = primary_contact.phone if ceo.phone.blank?
    ceo.fax = primary_contact.fax unless ceo.fax
    ceo.address = primary_contact.address if ceo.address.blank?
    ceo.address_more = primary_contact.address_more unless ceo.address_more
    ceo.city = primary_contact.city if ceo.city.blank?
    ceo.state = primary_contact.state unless ceo.state
    ceo.postal_code = primary_contact.postal_code unless ceo.postal_code
    ceo.country_id = primary_contact.country_id unless ceo.country
  end

  def set_ceo_attributes(par)
    ceo.attributes = par
  end

  def valid_ceo?
    ceo.valid? && unique_emails?
  end

  def has_pledge?
    false
  end

  # checks the organization's country and Local Network to display correct pledge form
  def pledge_form_type
    organization.collaborative_funding_model? ? 'pledge_form_collaborative' : 'pledge_form_independent'
  end

  def save
    before_save

    organization.save
    primary_contact.save
    ceo.save
    organization.contacts << primary_contact
    organization.contacts << ceo

    after_save
  end


  def before_save; end
  def after_save; end

  private

    # Makes sure the CEO and Contact point don't have the same email address
    def unique_emails?
      unique = (ceo.email.try(:downcase) != primary_contact.email.try(:downcase))
      ceo.errors.add :email, "cannot be the same as the Contact Point" unless unique
      return unique
    end

    def validate_country
      return if organization.country.present?
      organization.errors.add :country_id, "can't be blank"
    end

    def validate_type
      return if organization.organization_type.present?
      organization.errors.add :organization_type, "can't be blank"
    end

end
