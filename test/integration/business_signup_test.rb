require "test_helper"

class BusinessSignupTest < ActionDispatch::IntegrationTest

  setup do
    create(:country, name: "Canada")
    create(:country, name: "Norway")
    create(:listing_status, name: "Publicly Listed")
    create(:exchange, name: "ABC-Index")
    travel_to Date.new(2019, 1, 1)
  end

  teardown do
    travel_back
  end

  test "a valid business signup" do
    # Given a parent company
    parent_company = create(:business)

    # and a country from a network that requires invoicing
    create(:country,
      name: "France",
      local_network: create(:local_network, invoice_options_available: "yes"))

    # and 3 Action Platforms
    platform1, platform2, _ = create_list(:action_platform_platform, 3)

    # step 1
    step1 = TestPage::Signup::Step1.new
    step1.visit

    step2 = step1.submit(
      organization_name: "New Organization name",
      website: "http://some-website.org",
      employees: "123",
      ownership: "Publicly Listed",
      exchange: "ABC-Index",
      stock_symbol: "ABCD",
      sector: "Mining",
      revenue: "$250,000,000",
      country: "France",
      subsidiary?: true,
      parent_company_id: parent_company.id,
      parent_company_name: parent_company.name,
      tobacco?: true,
      landmines?: true,
    )
    assert_equal organization_step2_path, current_path, validation_errors

    step3 = step2.submit(
      prefix: "Mr.",
      first_name: "Michael",
      middle_name: "B.",
      last_name: "Henry",
      title: "Contract specialist",
      email: "MichaelBHenry@rhyta.com",
      phone: "418-670-0163",
      street: "4283 rue Garneau",
      street2: "Suite B",
      city: "Quebec",
      state: "QC",
      postal_code: "G1V 3V5",
      country: "Canada",
      username: "Runcest",
      password: "xou5Eboh",
    )
    assert_equal organization_step3_path, current_path, validation_errors

    step4 = step3.submit(
      prefix: "Ms.",
      first_name: "Doris",
      middle_name: "P",
      last_name: "Frafjord",
      title: "CEO",
      email: "DorisFrafjord@teleworm.us",
      phone: "985 78 958",
      street: "Eirik Jarls gate 157",
      street2: "",
      city: "TRONDHEIM",
      state: "TRONDHEIM",
      postal_code: "7030",
      country: "Norway",
    )
    assert_equal organization_step4_path, current_path, validation_errors

    # step4 level of participation, invoice date, action platforms
    step4.select_engagement_tier("PARTICIPANT + ACTION PLATFORMS & LEAD ELIGIBILITY")
    step4.subscribe_to_action_platform(platform1, "Michael Henry")
    step4.subscribe_to_action_platform(platform2, "Michael Henry")
    step5 = step4.submit
    assert_equal organization_step5_path, current_path, validation_errors

    # step5 financial contact info
    step5.fill_in_contact(
      prefix: "Mrs.",
      first_name: "Lisandra",
      last_name: "Mueller",
      title: "CTO",
      email: "limueller@block.name",
      phone: "(123) 123 1234",
    )
    step6 = step5.submit
    assert_equal organization_step6_path, current_path, validation_errors

    # step 6 Letter of Commitment
    step6.submit(
      commitment_letter: "test/fixtures/files/untitled.pdf",
      registry_url: "http://myregistry.org",
    )
    assert_equal organization_step7_path, current_path, validation_errors

    # verify
    # organization
    organization = Organization.find_by! name: "New Organization name"
    assert_equal "New Organization name", organization.name
    assert_equal "http://some-website.org", organization.url
    assert_equal 123, organization.employees
    assert_equal "Publicly Listed", organization.listing_status.name
    assert_equal "ABC-Index", organization.exchange.name
    assert_equal "ABCD", organization.stock_symbol
    assert_equal "Mining", organization.sector.name
    assert_equal 250_000_000_00, organization.precise_revenue.cents
    assert_equal "SME", organization.organization_type.name
    assert_equal "France", organization.country.name
    assert_not_nil organization.parent_company
    assert organization.is_tobacco?
    assert organization.is_landmine?
    assert_nil organization.legal_status
    assert_equal Date.new(2019, 1, 1), organization.invoice_date
    assert_equal "participant_level", organization.level_of_participation
    assert_equal "http://myregistry.org", organization.government_registry_url

    # commitment letter
    commitment_letter_file_name = organization.commitment_letter_file_name
    assert_equal "untitled.pdf", commitment_letter_file_name

    # contact point
    cp = organization.contacts.contact_points.first
    assert_equal "Mr.", cp.prefix
    assert_equal "Michael", cp.first_name
    assert_equal "B.", cp.middle_name
    assert_equal "Henry", cp.last_name
    assert_equal "Contract specialist", cp.job_title
    assert_equal "MichaelBHenry@rhyta.com", cp.email
    assert_equal "418-670-0163", cp.phone
    assert_equal "4283 rue Garneau", cp.address
    assert_equal "Suite B", cp.address_more
    assert_equal "Quebec", cp.city
    assert_equal "QC", cp.state
    assert_equal "G1V 3V5", cp.postal_code
    assert_equal "Canada", cp.country.name
    assert_nil cp.welcome_package
    assert_equal "runcest", cp.username
    assert cp.valid_password?("xou5Eboh")

    # ceo
    ceo = organization.contacts.ceos.first
    assert_equal "Ms.", ceo.prefix
    assert_equal "Doris", ceo.first_name
    assert_equal "P", ceo.middle_name
    assert_equal "Frafjord", ceo.last_name
    assert_equal "CEO", ceo.job_title
    assert_equal "DorisFrafjord@teleworm.us", ceo.email
    assert_equal "985 78 958", ceo.phone
    assert_equal "Eirik Jarls gate 157", ceo.address
    assert_equal "", ceo.address_more
    assert_equal "TRONDHEIM", ceo.city
    assert_equal "TRONDHEIM", ceo.state
    assert_equal "7030", ceo.postal_code
    assert_equal "Norway", ceo.country.name
    assert_nil ceo.username
    assert_nil ceo.encrypted_password

    # financial_contact
    financial_contact = organization.contacts.financial_contacts.first
    assert_not_nil financial_contact, "financial contact wasn't created"
    assert_equal "Mrs.", financial_contact.prefix
    assert_equal "Lisandra", financial_contact.first_name
    assert_equal "", financial_contact.middle_name
    assert_equal "Mueller", financial_contact.last_name
    assert_equal "CTO", financial_contact.job_title
    assert_equal "limueller@block.name", financial_contact.email
    assert_equal "(123) 123 1234", financial_contact.phone
    assert_equal cp.address, financial_contact.address
    assert_equal cp.address_more, financial_contact.address_more
    assert_equal cp.city, financial_contact.city
    assert_equal cp.state, financial_contact.state
    assert_equal cp.postal_code, financial_contact.postal_code
    assert_equal cp.country.name, financial_contact.country.name

    # There should be 2 pending action platform subscriptions
    assert_equal 2, ActionPlatform::Subscription.where(organization: organization).count
  end

  test "financial contact can be the same as primary contact"  do
    platform = create(:action_platform_platform)

    step1 = TestPage::Signup::Step1.new
    # step 1
    step1 = TestPage::Signup::Step1.new
    step1.visit

    step2 = step1.submit(
      organization_name: "New Organization name",
      website: "http://some-website.org",
      employees: "123",
      ownership: "Publicly Listed",
      exchange: "ABC-Index",
      stock_symbol: "ABCD",
      sector: "Mining",
      revenue: "$250,000,000",
      country: "Norway",
      subsidiary?: false,
      tobacco?: true,
      landmines?: true,
    )
    assert_equal organization_step2_path, current_path, validation_errors

    step3 = step2.submit(
      prefix: "Mr.",
      first_name: "Michael",
      middle_name: "B.",
      last_name: "Henry",
      title: "Contract specialist",
      email: "MichaelBHenry@rhyta.com",
      phone: "418-670-0163",
      street: "4283 rue Garneau",
      street2: "Suite B",
      city: "Quebec",
      state: "QC",
      postal_code: "G1V 3V5",
      country: "Canada",
      username: "Runcest",
      password: "xou5Eboh",
    )
    assert_equal organization_step3_path, current_path, validation_errors

    step4 = step3.submit(
      prefix: "Ms.",
      first_name: "Doris",
      middle_name: "P",
      last_name: "Frafjord",
      title: "CEO",
      email: "DorisFrafjord@teleworm.us",
      phone: "985 78 958",
      street: "Eirik Jarls gate 157",
      street2: "",
      city: "TRONDHEIM",
      state: "TRONDHEIM",
      postal_code: "7030",
      country: "Norway",
    )
    assert_equal organization_step4_path, current_path, validation_errors

    # step4 level of participation, invoice date, action platforms
    step4.select_engagement_tier("PARTICIPANT + ACTION PLATFORMS & LEAD ELIGIBILITY")
    step4.subscribe_to_action_platform(platform, "Michael Henry")
    step5 = step4.submit
    assert_equal organization_step5_path, current_path, validation_errors

    # step5 financial contact info
    step5.check_same_as_primary_contact
    step6 = step5.submit
    assert_equal organization_step6_path, current_path, validation_errors

    # step 6 Letter of Commitment
    assert_difference -> { Contact.count }, +2 do
      step6.submit(commitment_letter: "test/fixtures/files/untitled.pdf",
        registry_url: "http://myregistry.org")
    end
    assert_equal organization_step7_path, current_path, validation_errors

    organization = Organization.find_by(name: "New Organization name")
    financial_contact = organization.contacts.financial_contacts.first
    assert_not_nil financial_contact
    assert_equal "Michael Henry", financial_contact.name
  end

  private

  def validation_errors
    errors = all(".error-list .error")
    if errors.empty?
      errors = all(".errors-container .error")
    end
    errors.map(&:text).join("\n")
  end

  def t(*args)
    I18n.t(*args)
  end

end
