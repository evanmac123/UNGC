class OrganizationSignup
  attr_reader :org_type

  def initialize(org_type)
    @org_type = org_type
  end

  def business?
    org_type == 'business'
  end

  def non_business?
    org_type == 'non_business'
  end

  def organization
    @organization ||= Organization.new
  end

  def primary_contact
    @primary_contact ||= Contact.new_contact_point
  end

  def ceo
    @ceo ||= Contact.new_ceo
  end

  def financial_contact
    @financial_contact ||= Contact.new_financial_contact
  end

  def set_organization_attributes(par)
    organization.attributes = par
  end

  def set_primary_contact_attributes_and_prepare_ceo(par)
    primary_contact.attributes = par
    # ceo contact fields which default to contact
    ceo.phone = primary_contact.phone unless ceo.phone
    ceo.fax = primary_contact.fax unless ceo.fax
    ceo.address = primary_contact.address unless ceo.address
    ceo.address_more = primary_contact.address_more unless ceo.address_more
    ceo.city = primary_contact.city unless ceo.city
    ceo.state = primary_contact.state unless ceo.state
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

  def step7(par)
    organization.attributes = par
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
end
