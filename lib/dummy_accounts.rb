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
    create_approved_organization(
      name: 'Dummy Business',
      employees: 23,
      organization_type: OrganizationType.sme,
      sector: Sector.first,
      listing_status: ListingStatus.publicly_listed,
      stock_symbol: 'DUMMY_BUSINESS',
      contact: {
        username: 'dummy.business',
        password: 'Dummy1.business',
        first_name: 'Business',
        last_name: 'Contact',
        email: 'dummy.business@unglobalcompact.org'
      }
    )
  end

  def non_business_organization
    register(create_approved_organization(
      name: 'Dummy Non-Business',
      employees: 10000,
      organization_type: OrganizationType.academic,
      contact: {
        username: 'dummy.non-business',
        password: 'Dummy1.non-business',
        first_name: 'Non-Business',
        last_name: 'Contact',
        email: 'dummy.non-business@unglobalcompact.org'
      }
    ))
  end

  def local_network_account
    create_contact(
      username: 'dummy.local-network',
      password: 'Dummy1.local-network',
      first_name: 'Local-Network',
      last_name: 'Contact',
      email: 'dummy.local-network@unglobalcompact.org',
      local_network: canada.local_network,
      roles: [Role.contact_point]
    )
  end

  def reporting_business_organization
    create_approved_organization(
      name: 'Dummy Reporting Business',
      employees: 64,
      organization_type: OrganizationType.sme,
      sector: Sector.first,
      listing_status: ListingStatus.publicly_listed,
      stock_symbol: 'DUMMY_REPORTING_BUSINESS',
      contact: {
        username: 'dummy.reporting.business',
        password: 'Dummy1.reporting.business',
        first_name: 'Reporting-Business',
        last_name: 'Contact',
        email: 'dummy.reporting.business@unglobalcompact.org'
      }
    )
  end

  def reporting_non_business_organization
    organization = create_approved_organization(
      name: 'Non-Business Org',
      employees: 659,
      organization_type: OrganizationType.academic,
      contact: {
        username: 'dummy.reporting.non-business',
        password: 'Dummy1.reporting.non-business',
        first_name: 'Reporting-Non-Business',
        last_name: 'Contact',
        email: 'dummy.reporting.non-business@unglobalcompact.org'
      }
    )
    register(organization)
  end

  def reporting_local_network_account
    create_contact(
      username: 'dummy.reporting.local-network',
      password: 'Dummy1.reporting.local-network',
      first_name: 'Reprting-Local-Network',
      last_name: 'Contact',
      email: 'dummy.reporting.local-network@unglobalcompact.org',
      local_network: canada.local_network,
      roles: [Role.network_report_recipient]
    )
  end

  private

  def create_contact(params)
    params.reverse_merge!(
      prefix: 'Ms.',
      address: '123 Green Street',
      country: canada,
      city: 'Toronto',
      job_title: 'Dummy Account',
      phone: '1234567890'
    )
    username = params.fetch(:username)
    Contact.where(username: username).first_or_create!(params)
  end

  def create_approved_organization(params)
    contact_params = params.delete(:contact)
    params.reverse_merge!(contacts: [create_contact(contact_params)])
    params.reverse_merge!(country: canada)

    Organization.where(name: params.fetch(:name))
                .first_or_create!(params, &:approve!)
  end

  def register(organization)
    organization.registration.update_attributes!(
      date: Date.current - 1.year,
      place: 'Registration place',
      authority: 'Some authority',
      mission_statement: 'We will support the UNGC',
      number: rand(999).to_s
    )
    organization
  end

  def canada
    @canada ||= Country.find_by(code: 'ca')
  end

end
