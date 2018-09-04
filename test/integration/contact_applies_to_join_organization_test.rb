require 'test_helper'

class ContactAppliesToJoinOrganizationTest < ActionDispatch::IntegrationTest

  test "accepts valid contact input" do
    # Given an organization and a country
    organization = create(:organization)
    country = create(:country)

    # When the form is filled out
    visit new_contact_path

    fill_in "Organization name", with: organization.name
    fill_in "Prefix", with: "Ms."
    fill_in "First name", with: "Eugenia"
    fill_in "Middle name", with: "T."
    fill_in "Last name", with: "Change"
    fill_in "Job title", with: "Baker/Mathematician"
    fill_in "Email", with: "eugenia@example.com"
    fill_in "Phone", with: "+1-234-567-8910"
    fill_in "Postal address", with: "123 Fake St."
    fill_in "Address cont.", with: "Suite 200"
    fill_in "City", with: "Mathtown"
    fill_in "State/Province", with: "NV"
    fill_in "Country", with: country.name
    fill_in "ZIP/Code", with: "90210"

    # simulate matching on the organization name:
    find("#contact_organization_id", visible: false).set(organization.id)

    # simulate matching on the country name:
    find("#contact_country_id", visible: false).set(country.id)

    click_on "Add contact"

    # Then we should see a success message
    assert_equal 200, page.status_code
    assert page.has_content?(I18n.t("organization.requested_to_join"))
  end

  test "rejects invalid input" do
    # Given an organization
    organization = create(:organization)

    # When the form is submitted without all the fields
    visit new_contact_path
    find("#contact_organization_id", visible: false).set(organization.id)
    click_on "Add contact"

    # Then we see a validation error
    assert page.has_content?("First name can't be blank"),
      "Can't find 'First name' validation error on the page"
  end

end
