class OrganizationSignup
  attr_reader :org_type, :organization, :registration, :primary_contact, :ceo, :financial_contact

  def initialize(org_type)
    @org_type = org_type || 'business'
    @organization = Organization.new
    @registration = @organization.build_non_business_organization_registration
    @primary_contact = Contact.new_contact_point
    @ceo = Contact.new_ceo
    @financial_contact = Contact.new_financial_contact
  end

  def business?
    org_type == 'business'
  end

  def non_business?
    org_type == 'non_business'
  end

  def set_legal_status(org)
    if org && org[:legal_status]
      lg = UploadedFile.new attachable_type: 'Organization', attachable_key: Organization::ORGANIZATION_FILE_TYPES[:legal_status]
      lg.attachment = org[:legal_status]
      lg.save!
      @legal_status_id = lg.id
      org.delete(:legal_status)
    end
  end

  def set_organization_attributes(org, reg=nil)
    set_legal_status(org)
    organization.attributes = org
    registration.attributes = reg
  end

  def set_primary_contact_attributes(par)
    primary_contact.attributes = par
  end

  def prepare_ceo
    # ceo contact fields which default to contact
    ceo.phone = primary_contact.phone if ceo.phone.blank?
    ceo.fax = primary_contact.fax unless ceo.fax
    ceo.address = primary_contact.address if ceo.address.blank?
    ceo.address_more = primary_contact.address_more unless ceo.address_more
    ceo.city = primary_contact.city if ceo.city.blank?
    ceo.state = primary_contact.state if ceo.state
    ceo.postal_code = primary_contact.postal_code unless ceo.postal_code
    ceo.country_id = primary_contact.country_id unless ceo.country
  end

  def set_ceo_attributes(par)
    ceo.attributes = par
  end

  def set_financial_contact_attributes(par)
    if par[:foundation_contact].to_i == 1
      primary_contact.roles << Role.financial_contact
    else
      financial_contact.attributes = par
    end
  end

  def prepare_financial_contact
    financial_contact.address = primary_contact.address
    financial_contact.address_more = primary_contact.address_more
    financial_contact.city = primary_contact.city
    financial_contact.state = primary_contact.state
    financial_contact.postal_code = primary_contact.postal_code
    financial_contact.country_id = primary_contact.country_id
  end

  # Makes sure the CEO and Contact point don't have the same email address
  def unique_emails?
    unique = (ceo.email.try(:downcase) != primary_contact.email.try(:downcase))
    ceo.errors.add :email, "cannot be the same as the Contact Point" unless unique
    return unique
  end

  def valid_organization?(complete=false)
    organization.valid?
    if non_business?
      if @legal_status_id.blank?
        organization.errors.add :legal_status, "can't be blank"
      end
    end

    if complete
      if !organization.commitment_letter?
        organization.errors.add :commitment_letter, "Please upload."
      end
    end
    !organization.errors.any?
  end

  def valid_registration?(complete=false)
    registration.valid?
    if non_business?
      if registration.number.blank?
        registration.errors.add :number, "can't be empty"
      end

      if complete
        if registration.mission_statement.blank?
          registration.errors.add :mission_statement, "can't be empty"
        elsif registration.mission_statement.length > 1000
          registration.errors.add :mission_statement, "has to be less that 1000 characters"
        end
      end
    end
    !registration.errors.any?
  end

  def save
    # save all records
    if @legal_status_id
      organization.legal_status = UploadedFile.find(@legal_status_id)
    end

    organization.save
    primary_contact.save
    ceo.save
    organization.contacts << primary_contact
    organization.contacts << ceo

    if non_business?
      registration.save
    else
      @registration = nil
    end

    # add financial contact if a pledge was made and the existing contact has not been assigned that role
    if !organization.pledge_amount.blank? && !primary_contact.is?(Role.financial_contact)
      financial_contact.save
      organization.contacts << financial_contact
    end
  end

end
