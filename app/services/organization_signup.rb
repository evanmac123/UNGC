class OrganizationSignup
  attr_reader :organization
  attr_reader :primary_contact, :ceo, :org_type

  def initialize
    @organization = Organization.new
    @primary_contact = Contact.new_contact_point
    @ceo = Contact.new_ceo
    post_initialize
  end

  def post_initialize
  end

  def types
    raise NotImplementedError
  end

  def business?; org_type == 'business' end
  def non_business?; !business? end

  def set_organization_attributes(params)
    organization.attributes = params
    primary_contact.country_id = organization.country_id
  end

  def set_registration_attributes(registration_params)
    # no-op
  end

  def set_pledge_attributes(params)
    organization.attributes = params.slice(:pledge_amount, :no_pledge_reason)
  end

  def set_commitment_letter_attributes(params)
    organization.commitment_letter = params.fetch(:commitment_letter)
  end

  def pledge_complete?
    raise NotImplementedError
  end

  def pledge_incomplete?
    !pledge_complete?
  end

  def valid?
    valid_organization?
  end

  def complete_valid?
    complete_valid_organization?
  end

  def valid_organization?
    organization.valid?
    validate_type
    validate_country
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

  def require_pledge?
    false
  end

  def save
    # TODO fix this.
    # No transaction and no exceptions mean that
    # any failures here will not be detected and we may have invalid/partial data.
    # see https://github.com/unspace/UNGC/issues/360
    before_save

    organization.save
    # fixes bug caused by storing signup and related objects in session (in rails4)
    primary_contact.roles.reload
    primary_contact.save
    # fixes bug caused by storing signup and related objects in session (in rails4)
    ceo.roles.reload
    ceo.save
    organization.contacts << primary_contact
    organization.contacts << ceo

    after_save
  end


  # these are hook methods that can be implemented by the subclasses
  def before_save; end
  def after_save; end
  def local_valid_organization?; end

  private

    # Makes sure the CEO and Contact point don't have the same email address
    def unique_emails?
      unique = (ceo.email.try(:downcase) != primary_contact.email.try(:downcase))
      ceo.errors.add :email, "cannot be the same as the Contact Point" unless unique
      return unique
    end

    def validate_country
      return if organization.country.present?
      organization.errors.add :country_id, "must be selected"
    end

    def validate_type
      return if organization.organization_type.present?
      organization.errors.add :organization_type_id, "must be selected"
    end

end
