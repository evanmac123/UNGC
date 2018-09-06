require 'test_helper'

class RequestAcademyAccessTest < ActionDispatch::IntegrationTest

  setup { create(:role, name: Role::FILTERS[:academy_viewer]) }

  test "accepts valid contact input" do
    # Given an organization and a country
    organization = create(:organization)
    country = create(:country)

    # When the form is filled out
    visit new_academy_viewer_path

    fill_in "Organization name", with: organization.name
    fill_in "Prefix", with: "Ms."
    fill_in "First name", with: "Eugenia"
    fill_in "Middle name", with: "T."
    fill_in "Last name", with: "Cheng"
    fill_in "Job title", with: "Baker/Mathematician"
    fill_in "Email", with: "eugenia@example.com"
    fill_in "Phone", with: "+1-234-567-8910"
    fill_in "Postal address", with: "123 Fake St."
    fill_in "Address cont.", with: "Suite 200"
    fill_in "City", with: "Mathtown"
    fill_in "State/Province", with: "NV"
    fill_in "Country", with: country.name
    fill_in "ZIP/Code", with: "90210"
    fill_in "Username", with: "echeng"

    click_on "Add contact"

    # Then we should see a success message
    assert page.has_content?(I18n.t("organization.requested_to_join")), validation_errors
  end

  test "accept new academy viewer" do
    organization = create(:organization)
    country = create(:country)
    attrs = attributes_for(:contact,
                           organization_id: organization.id,
                           country_id: country.id)
    viewer = Academy::Viewer.new(attrs)
    assert viewer.save, viewer.errors.full_messages

    email = ActionMailer::Base.deliveries.last
    link = email.body.to_s.scan(/\/academy\/viewers\/.+\/accept/).first
    visit link

    welcome_email = ActionMailer::Base.deliveries.last
    assert_equal "Welcome to the UN Global Compact Academy", welcome_email.subject
    assert_match(/reset_password_token=[A-Za-z\d]/, welcome_email.text_part.body.to_s)

    assert_no_difference -> { ActionMailer::Base.deliveries.size } do
      visit link
    end
  end

  test "accept request to claim a contact" do
    organization = create(:organization)
    country = create(:country)
    contact = create(:contact,
                     organization_id: organization.id,
                     country_id: country.id,
                     username: nil,
                     encrypted_password: nil)

    attributes = {
      prefix: contact.prefix,
      first_name: contact.first_name,
      middle_name: contact.middle_name,
      last_name: contact.last_name,
      job_title: contact.job_title,
      email: contact.email,
      phone: contact.phone,
      city: contact.city,
      state: contact.state,
      country_id: contact.country.id,
      postal_code: contact.postal_code,
      address: contact.address,
      address_more: contact.address_more,
      organization_id: contact.organization.id,
      username: "foobar",
    }

    viewer = Academy::Viewer.new(attributes)
    assert viewer.save, viewer.errors.full_messages

    email = ActionMailer::Base.deliveries.last
    link = email.body.to_s.scan(/\/academy\/viewers\/.+\/accept/).first
    visit link

    reset_email = ActionMailer::Base.deliveries.last
    assert_equal "United Nations Global Compact - Reset Password", reset_email.subject

    assert_no_difference -> { ActionMailer::Base.deliveries.size } do
      visit link
    end
  end

  test "rejects invalid input" do
    # Given an organization
    organization = create(:organization)

    # When the form is submitted without all the fields
    visit new_academy_viewer_path
    find("#viewer_organization_id", visible: false).set(organization.id)
    click_on "Add contact"

    # Then we see a validation error
    assert page.has_content?("First name can't be blank"),
      "Can't find 'First name' validation error on the page"
  end

  private

  def validation_errors
    all(".errors-list li").map(&:text).to_sentence
  end

end
