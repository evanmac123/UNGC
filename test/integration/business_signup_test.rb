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

    # step 1
    visit "/participation/join/application/step1/business"

    fill_in "Organization Name", with: "New Organization name"
    fill_in "Website", with: "http://some-website.org"
    fill_in "Employees", with: "123"
    select "Publicly Listed", from: "Ownership"
    select "ABC-Index", from: "Exchange", visible: false
    fill_in "Stock symbol", with: "ABCD", visible: false
    select "Mining", from: "Sector", visible: false
    fill_in I18n.t("level_of_participation.confirm_annual_revenue"), with: "$250,000,000"
    select "France", from: "Country"
    within("label[for='organization_is_subsidiary']") { choose "Yes" }
    fill_in "organization_parent_company_name", with: parent_company.name
    simulate_parent_company_selection(parent_company)
    within("label[for='organization_is_tobacco']") { choose "Yes" }
    within("label[for='organization_is_landmine']") { choose "Yes" }

    click_on "Next"
    assert_equal organization_step2_path, current_path, validation_errors

    # step2
    fill_in "Prefix", with: "Mr."
    fill_in "First name", with: "Michael"
    fill_in "Middle name", with: "B."
    fill_in "Last name", with: "Henry"
    fill_in "Job title", with: "Contract specialist"
    fill_in "Email", with: "MichaelBHenry@rhyta.com"
    fill_in "Phone", with: "418-670-0163"
    fill_in "Postal address", with: "4283 rue Garneau"
    fill_in "Address cont.", with: "Suite B"
    fill_in "City", with: "Quebec"
    fill_in "State/Province", with: "QC"
    fill_in "ZIP/Code", with: "G1V 3V5"
    select "Canada", from: "Country"
    fill_in "Username", with: "Runcest"
    fill_in "Password", with: "xou5Eboh"

    click_on "Next"
    assert_equal organization_step3_path, current_path, validation_errors

    # step3
    fill_in "Prefix", with: "Ms."
    fill_in "First name", with: "Doris"
    fill_in "Middle name", with: "P"
    fill_in "Last name", with: "Frafjord"
    fill_in "Job title", with: "CEO"
    fill_in "Email", with: "DorisFrafjord@teleworm.us"
    fill_in "Phone", with: "985 78 958"
    fill_in "Postal address", with: "Eirik Jarls gate 157"
    fill_in "Address cont.", with: ""
    fill_in "City", with: "TRONDHEIM"
    fill_in "State/Province", with: "TRONDHEIM"
    fill_in "ZIP/Code", with: "7030"
    select "Norway", from: "Country"

    click_on "Next"
    assert_equal organization_step4_path, current_path, validation_errors

    # step4 level of participation, invoice date
    choose "PARTICIPANT"

    click_on "Next"
    assert_equal organization_step5_path, current_path, validation_errors

    # step5 financial contact info
    fill_in "Prefix", with: "Mrs."
    fill_in "First name", with: "Lisandra"
    fill_in "Last name", with: "Mueller"
    fill_in "Job title", with: "CTO"
    fill_in "Email", with: "limueller@block.name"
    fill_in "Phone", with: "(123) 123 1234"

    today = Time.zone.now.strftime("%d/%m/%Y")
    fill_in "organization[invoice_date]", with: today

    click_on "Next"
    assert_equal organization_step6_path, current_path, validation_errors

    # step 6 Letter of Commitment
    attach_file "organization_commitment_letter", "test/fixtures/files/untitled.pdf"
    click_on "Submit"
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

  def simulate_parent_company_selection(parent_company)
    find(:xpath, "//input[@id='organization_parent_company_id']", visible: :all).set(parent_company.id)
  end

end
