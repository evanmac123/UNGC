require 'test_helper'

class OrganizationSignupTest < ActiveSupport::TestCase

  test "have an organization type" do
    signup = BusinessOrganizationSignup.new
    assert_equal signup.business?, true
    assert_equal signup.non_business?, false
  end

  test "have an organization" do
    signup = BusinessOrganizationSignup.new
    assert_not_nil signup.organization
  end

  test "have a primary_contact" do
    signup = BusinessOrganizationSignup.new
    assert_contains signup.primary_contact.roles, Role.contact_point
  end

  test "have a ceo" do
    signup = BusinessOrganizationSignup.new
    assert_contains signup.ceo.roles, Role.ceo
  end

  test "have a financial contact" do
    signup = BusinessOrganizationSignup.new
    assert_contains signup.financial_contact.roles, Role.financial_contact
  end

  test "set organization attributes" do
    signup = BusinessOrganizationSignup.new
    signup.set_organization_attributes(name: "Foo")

    assert_equal "Foo", signup.organization.name
  end

  test "the primary contact will have the same country as the organization" do
    country = create(:country)
    signup = BusinessOrganizationSignup.new
    signup.set_organization_attributes(country: country)

    assert_equal country, signup.organization.country
    assert_equal country, signup.primary_contact.country
  end

  test "set primary contact" do
    signup = BusinessOrganizationSignup.new
    signup.set_primary_contact_attributes(first_name: "Alice")
    assert_equal "Alice", signup.primary_contact.first_name
  end

  test "prepare_ceo defaults any fields from the primary contact to the ceo" do
    signup = BusinessOrganizationSignup.new

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
    signup = BusinessOrganizationSignup.new
    signup.set_ceo_attributes(first_name: "foo")
    assert_equal "foo", signup.ceo.first_name
  end

  test "set financial contact attributes" do
    signup = BusinessOrganizationSignup.new
    signup.set_financial_contact_attributes(city: "nowheresville")
    assert_equal "nowheresville", signup.financial_contact.city
  end

  test "prepare_financial_contact defaults any fields from the primary contact to the financial contact" do
    signup = BusinessOrganizationSignup.new

    primary_contact = build(:contact)
    signup.set_primary_contact_attributes(primary_contact.attributes)
    signup.set_financial_contact_attributes(first_name: "Alice", last_name: "Walker")

    signup.prepare_financial_contact

    financial_contact = signup.financial_contact
    assert_equal primary_contact.address, financial_contact.address
    assert_equal primary_contact.city, financial_contact.city
    assert_equal "Alice Walker", financial_contact.name
  end

  test "set primary contact as financial contact" do
    signup = BusinessOrganizationSignup.new
    signup.set_financial_contact_attributes(foundation_contact: "1")
    assert signup.primary_contact.is? Role.financial_contact
  end

  test "persist the organization and the contacts" do
    # Given a signup that requires a financial contact
    signup = build_signup(pledge: { pledge_amount: "100" })
    assert signup.save, signup.error_messages

    assert signup.organization.persisted?
    assert signup.primary_contact.persisted?
    assert signup.ceo.persisted?
    assert signup.financial_contact.persisted?
    assert signup.organization.commitment_letter.present?
  end

  test "persist participation level" do
    signup = build_signup(organization: { level_of_participation: "signatory_level" })
    assert signup.save, signup.error_messages
    assert signup.organization.reload.signatory_level?
  end

  test "require revenue questions" do
    signup = BusinessOrganizationSignup.new

    refute signup.valid?, "expected signup not to be valid"
    assert_contains signup.error_messages, "Revenue from tobacco must be selected"
    assert_contains signup.error_messages, "Revenue from landmines must be selected"
  end

  test "validates invoice_date according to a policy" do
    signup = build_signup()
    signup.invoicing_policy = stub(invoicing_required?: true)

    refute signup.valid_invoice_date?, "expected signup not to be valid"
    assert_contains signup.error_messages, "Invoice date can't be blank"
  end

  test "persist revenue questions" do
    signup = build_signup(organization: {
      is_tobacco: "false",
      is_landmine: "true",
    })
    assert signup.save, signup.error_messages

    organization = signup.organization.reload
    assert_equal false, organization.is_tobacco
    assert_equal true, organization.is_landmine
  end

  private

  def new_contact_attributes
    attributes_for(:contact).merge(password: "Passw0rd")
  end

  def build_signup(params = {})
    signup = BusinessOrganizationSignup.new

    # step1
    org_params = new_business_attributes(params.fetch(:organization, {}))
    signup.set_organization_attributes(org_params)

    # step2
    signup.set_primary_contact_attributes(new_contact_attributes)

    # step3
    signup.set_ceo_attributes(new_contact_attributes)
    signup.prepare_ceo

    # step4
    signup.select_participation_level(
      level_of_participation: "signatory_level",
    )

    # step5
    signup.set_financial_contact_attributes(new_contact_attributes)
    signup.prepare_financial_contact

    # step6
    signup.set_commitment_letter_attributes(
      commitment_letter: fixture_pdf_file
    )

    signup
  end

  def new_business_attributes(params = {})
    build(:business, params.reverse_merge(
      sector_id: create(:sector).id.to_s,
      listing_status_id: create(:listing_status).id.to_s,
      revenue: "2",
      is_landmine: "true",
      is_tobacco: "true",
      is_biological_weapons: "true",
      level_of_participation: "participant_level"
    )).attributes
  end

end
