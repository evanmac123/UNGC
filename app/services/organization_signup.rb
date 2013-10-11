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
    return @primary_contact if @primary_contact
    @primary_contact = Contact.new
    @primary_contact.role_ids = Role.contact_point.id
    @primary_contact
  end

  def ceo
    return @ceo if @ceo
    @ceo = Contact.new
    @ceo.role_ids = Role.ceo.id
    @ceo
  end

  def step2(par)
    organization.attributes = par
  end

  def step3(par)
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

  def step6(par)
    ceo.attributes = par
  end

  def step7(par)
    organization.attributes = par
  end

  # Makes sure the CEO and Contact point don't have the same email address
  def unique_emails?
    unique = (ceo.email.try(:downcase) != primary_contact.email.try(:downcase))
    ceo.errors.add :email, "cannot be the same as the Contact Point" unless unique
    return unique
  end
end
