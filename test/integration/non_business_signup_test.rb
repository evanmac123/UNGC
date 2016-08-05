require 'test_helper'

class NonBusinessSignupTest < ActionDispatch::IntegrationTest

  setup do
    create_roles
    create(:organization_type, name: 'City', type_property: OrganizationType::NON_BUSINESS)
    create(:country, name: 'France')
    create(:country, name: 'Canada')
    create(:country, name: 'Norway')
  end

  test "a valid non business signup" do
    # step 1
    visit '/participation/join/application/step1/non_business'
    fill_in 'Organization Name', with: 'New Organization name'
    fill_in 'Website', with: 'http://some-website.org'
    fill_in 'Employees', with: '123'
    select 'City', from: 'Type'
    select 'France', from: 'Country'
    fill_in 'Date of Registration', with: '2015-03-03'
    fill_in 'Place of Registration', with: 'Toronto'
    fill_in 'Public Authority', with: 'Some authority'
    fill_in 'Registration number', with: '12345'

    click_on 'Next'
    assert_equal organization_step2_path, current_path, validation_errors

    # step2 Primary contact point
    fill_in 'Prefix', with: 'Mr.'
    fill_in 'First name', with: 'Michael'
    fill_in 'Middle name', with: 'B.'
    fill_in 'Last name', with: 'Henry'
    fill_in 'Job title', with: 'Contract specialist'
    fill_in 'Email', with: 'MichaelBHenry@rhyta.com'
    fill_in 'Phone', with: '418-670-0163'
    fill_in 'Postal address', with: '4283 rue Garneau'
    fill_in 'Address cont.', with: 'Suite B'
    fill_in 'City', with: 'Quebec'
    fill_in 'State/Province', with: 'QC'
    fill_in 'ZIP/Code', with: 'G1V 3V5'
    select 'Canada', from: 'Country'
    fill_in 'Username', with: 'Runcest'
    fill_in 'Password', with: 'xou5Eboh'

    click_on 'Next'
    assert_equal organization_step3_path, current_path, validation_errors

    # step 3
    fill_in 'Prefix', with: 'Ms.'
    fill_in 'First name', with: 'Doris'
    fill_in 'Last name', with: 'Frafjord'
    fill_in 'Job title', with: 'CEO'
    fill_in 'Email', with: 'DorisFrafjord@teleworm.us'
    fill_in 'Phone', with: '985 78 958'
    fill_in 'Postal address', with: 'Eirik Jarls gate 157'
    fill_in 'Address cont.', with: ''
    fill_in 'City', with: 'TRONDHEIM'
    fill_in 'State/Province', with: 'TRONDHEIM'
    fill_in 'ZIP/Code', with: '7030'
    select 'Norway', from: 'Country'

    click_on 'Next'
    assert_equal organization_step6_path, current_path, validation_errors

    # step 6
    fill_in 'non_business_organization_registration_mission_statement', with: 'This is my mission.'
    attach_file 'organization_commitment_letter', 'test/fixtures/files/untitled.pdf'

    click_on 'Submit'
    assert_equal organization_step7_path, current_path, validation_errors

    # verify
    # organization
    organization = Organization.find_by! name: 'New Organization name'
    assert_equal 'New Organization name', organization.name
    assert_equal 'http://some-website.org', organization.url
    assert_equal 123, organization.employees
    assert_equal 'City', organization.organization_type.name
    assert_equal 'France', organization.country.name
    assert_nil organization.legal_status

    # commitment letter
    commitment_letter_file_name = organization.commitment_letter_file_name
    assert_equal 'untitled.pdf', commitment_letter_file_name

    # contact point
    cp = organization.contacts.contact_points.first
    assert_equal 'Mr.', cp.prefix
    assert_equal 'Michael', cp.first_name
    assert_equal 'B.', cp.middle_name
    assert_equal 'Henry', cp.last_name
    assert_equal 'Contract specialist', cp.job_title
    assert_equal 'MichaelBHenry@rhyta.com', cp.email
    assert_equal '418-670-0163', cp.phone
    assert_equal '4283 rue Garneau', cp.address
    assert_equal 'Suite B', cp.address_more
    assert_equal 'Quebec', cp.city
    assert_equal 'QC', cp.state
    assert_equal 'G1V 3V5', cp.postal_code
    assert_equal 'Canada', cp.country.name
    assert_equal 'runcest', cp.username
    assert cp.valid_password?('xou5Eboh')
    assert_nil cp.welcome_package

    # ceo
    ceo = organization.contacts.ceos.first
    assert_equal 'Ms.', ceo.prefix
    assert_equal 'Doris', ceo.first_name
    assert_equal '', ceo.middle_name
    assert_equal 'Frafjord', ceo.last_name
    assert_equal 'CEO', ceo.job_title
    assert_equal 'DorisFrafjord@teleworm.us', ceo.email
    assert_equal '985 78 958', ceo.phone
    assert_equal 'Eirik Jarls gate 157', ceo.address
    assert_equal '', ceo.address_more
    assert_equal 'TRONDHEIM', ceo.city
    assert_equal 'TRONDHEIM', ceo.state
    assert_equal '7030', ceo.postal_code
    assert_equal 'Norway', ceo.country.name
    assert_equal nil, ceo.welcome_package
    assert_equal true, ceo.is?(Role.ceo)
    assert_nil ceo.username
    assert_nil ceo.encrypted_password

    # registration
    registration = organization.non_business_organization_registration
    assert_equal Date.new(2015,3,3), registration.date
    assert_equal 'Toronto', registration.place
    assert_equal 'Some authority', registration.authority
    assert_equal '12345', registration.number
    assert_equal 'This is my mission.', registration.mission_statement
  end

  def validation_errors
    errors = all('#errorExplanation')
    if errors.any?
      ap errors.map(&:text).join('\n')
    end
  end

end
