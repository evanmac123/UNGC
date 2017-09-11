require 'test_helper'

class NonBusinessOrganizationSignupTest < ActiveSupport::TestCase

  test "have an organization type" do
    signup = NonBusinessOrganizationSignup.new
    assert_equal signup.business?, false
    assert_equal signup.non_business?, true
  end

  test "have an organization" do
    signup = NonBusinessOrganizationSignup.new
    assert_not_nil signup.organization
  end

  test "have a primary_contact" do
    signup = NonBusinessOrganizationSignup.new
    assert_not_nil signup.primary_contact
  end

  test "have a ceo" do
    signup = NonBusinessOrganizationSignup.new
    assert_not_nil signup.ceo
  end

  test "set organization attributes" do
    signup = NonBusinessOrganizationSignup.new
    signup.set_organization_attributes(name: "Foo")

    assert_equal "Foo", signup.organization.name
  end

  test "the primary contact will have the same country as the organization" do
    country = create(:country)
    signup = NonBusinessOrganizationSignup.new
    signup.set_organization_attributes(country: country)

    assert_equal country, signup.organization.country
    assert_equal country, signup.primary_contact.country
  end

  test "prepare_ceo defaults any fields from the primary contact to the ceo" do
    signup = NonBusinessOrganizationSignup.new

    primary_contact = build(:contact)
    signup.set_primary_contact_attributes(primary_contact.attributes)
    signup.set_ceo_attributes(first_name: "Alice", last_name: "Ceo")

    signup.prepare_ceo

    ceo = signup.ceo
    assert_equal primary_contact.phone, ceo.phone
    assert_equal primary_contact.address, ceo.address
    assert_equal "Alice Ceo", ceo.name
  end

  test "sets attributes on the CEO" do
    signup = NonBusinessOrganizationSignup.new
    signup.set_ceo_attributes(first_name: "foo")
    assert_equal "foo", signup.ceo.first_name
  end

  test "persist the organization and the contacts" do
    signup = create_signup
    assert signup.save, signup.error_messages

    assert signup.primary_contact.persisted?
    assert signup.ceo.persisted?
    assert signup.organization.persisted?
    assert signup.organization.non_business_organization_registration.persisted?
  end

  test "validate registration partially" do
    signup = build_signup(registration: { number: nil })
    assert !signup.valid_registration?, "should be invalid"

    signup.registration.number = "12345"
    assert signup.valid_registration?, signup.error_messages
  end

  test "validate registration completely" do
    signup = build_signup
    signup.registration.mission_statement = nil
    assert !signup.complete_valid_registration?, "should be invalid"

    signup.registration.mission_statement = "test"
    assert signup.complete_valid_registration?, signup.error_messages
  end

  test "validate organization partially" do
    signup = build_signup
    signup.organization.name = nil
    assert !signup.valid_organization?, "should be invalid"

    signup.set_organization_attributes(new_nonbusiness_attributes)
    assert signup.valid_organization?, signup.error_messages
  end

  test "validate organization completely" do
    signup = build_signup
    assert signup.complete_valid_organization?, signup.error_messages
  end

  test "validate presence of legal status only if registration.number is blank" do
    signup = build_signup(registration: { number: nil })
    refute signup.valid?, "should be invalid"

    legal_status = fixture_file_upload('files/untitled.pdf', 'application/pdf')
    signup.set_organization_attributes(legal_status: legal_status)
    assert signup.valid_organization?, signup.organization.errors.full_messages
  end

  private

  def new_contact_attributes
    attributes_for(:contact, password: "Passw0rd")
  end

  def build_signup(params = {})
    signup = NonBusinessOrganizationSignup.new

    org_params = new_nonbusiness_attributes(params.fetch(:organization, {}))
    signup.set_organization_attributes(org_params)

    reg_params = params.fetch(:registration, {}).reverse_merge(
      date: "2017-05-05",
      number: "12345",
      place: "Toronto",
      authority: "Me?",
      mission_statement: "I commit to amazingness"
    )
    signup.set_registration_attributes(reg_params)

    signup.set_primary_contact_attributes(new_contact_attributes)

    signup.set_ceo_attributes(new_contact_attributes)
    signup.prepare_ceo

    commitment_letter = fixture_file_upload('files/untitled.pdf', 'application/pdf')
    signup.organization.commitment_letter = commitment_letter

    signup
  end

  def create_signup(params = {})
    signup = build_signup(params)
    assert signup.complete_valid?, signup.error_messages
    assert signup.save, signup.error_messages
    signup
  end

  def new_nonbusiness_attributes(params = {})
    org_params = params.reverse_merge(
      is_landmine: true,
      is_tobacco: true,
      is_biological_weapons: true,
      level_of_participation: "participant_level"
    )
    organization = build(:non_business, org_params)
    organization.attributes
  end

end
