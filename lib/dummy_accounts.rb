class DummyAccounts

  def self.create
    new.create
  end

  def create
    business_organization
    non_business_organization
    local_network_account
    reporting_business_organization
    reporting_non_business_organization
    reporting_local_network_account
  end

  def business_organization
    create_organization(
      name: 'Dummy Business',
      employees: 23,
      organization_type: OrganizationType.sme,
      contact: {
        first_name: 'Business',
        last_name: 'Contact',
        email: 'dummy.business@unglobalcompact.org'
      }
    )
  end

  def non_business_organization
    create_organization(
      name: 'Dummy Non-Business',
      employees: 10000,
      organization_type: OrganizationType.academic,
      contact: {
        first_name: 'Non-Business',
        last_name: 'Contact',
        email: 'dummy.non-business@unglobalcompact.org'
      }
    )
  end

  def local_network_account
    create_contact(
      first_name: 'Local-Network',
      last_name: 'Contact',
      email: 'dummy.local-network@unglobalcompact.org',
      local_network: canada.local_network
    )
  end

  def reporting_business_organization
    create_organization(
      name: 'Dummy Reporting Business',
      employees: 64,
      organization_type: OrganizationType.sme,
      contact: {
        first_name: 'Reporting-Business',
        last_name: 'Contact',
        email: 'dummy.reporting.business@unglobalcompact.org'
      }
    )
  end

  def reporting_non_business_organization
    create_organization(
      name: 'Non-Business Org',
      employees: 659,
      organization_type: OrganizationType.academic,
      contact: {
        first_name: 'Reporting-Non-Business',
        last_name: 'Contact',
        email: 'dummy.reporting.non-business@unglobalcompact.org'
      }
    )
  end

  def reporting_local_network_account
    create_contact(
      first_name: 'Reprting-Local-Network',
      last_name: 'Contact',
      email: 'dummy.reporting.local-network@unglobalcompact.org',
      local_network: canada.local_network
    )
  end

  def create_contact(params)
    params.reverse_merge!(
      prefix: 'Ms.',
      address: '123 Green Street',
      country: Country.find_by(code: 'ca'),
      city: 'Toronto',
      job_title: 'Dummy Account',
      phone: '1234567890'
    )
    email = params.fetch(:email)
    Contact.where(email: email).first_or_create!(params)
  end

  def create_organization(params)
    contact_params = params.delete(:contact)
    params.reverse_merge!(contacts: [create_contact(contact_params)])
    name = params.fetch(:name)
    Organization.where(name: name).first_or_create!(params)
  end

  def canada
    @canada ||= Country.find_by(code: 'ca')
  end

end
