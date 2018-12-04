require 'test_helper'

class RequestAcademyAccessTest < ActionDispatch::IntegrationTest

  class TestExceptionLocalizationHandler
    def call(exception, locale, key, options)
      raise exception.to_exception
    end
  end

  setup do
    TestAfterCommit.enabled = true
    @default_exception_handler = I18n.exception_handler
    I18n.exception_handler = TestExceptionLocalizationHandler.new
    create(:role, name: Role::FILTERS[:academy_viewer])
  end

  teardown do
    TestAfterCommit.enabled = false
    I18n.exception_handler = @default_exception_handler
  end

  test "accepts valid contact input" do
    # Given an organization and a country
    organization = create(:organization)
    country = create(:country)

    # When the form is filled out
    visit new_academy_viewer_path

    viewer_page = Page.new
    viewer_page.fill_in_organization_name organization.name
    viewer_page.fill_in_prefix "Ms."
    viewer_page.fill_in_first_name "Eugenia"
    viewer_page.fill_in_middle_name "T."
    viewer_page.fill_in_last_name "Cheng"
    viewer_page.fill_in_job_title "Baker/Mathematician"
    viewer_page.fill_in_email "eugenia@example.com"
    viewer_page.fill_in_phone "+1-234-567-8910"
    viewer_page.fill_in_address "123 Fake St."
    viewer_page.fill_in_address_cont "Suite 200"
    viewer_page.fill_in_city "Mathtown"
    viewer_page.fill_in_state "NV"
    viewer_page.fill_in_country_name country.name
    viewer_page.fill_in_postal_code "90210"
    viewer_page.fill_in_username "echeng"
    viewer_page.submit

    # Then we should see a success message
    assert page.has_content?(I18n.t("organization.requested_to_join")), validation_errors + success_message
  end

  test "accept new academy viewer requests" do
    organization = create(:organization)
    country = create(:country)
    contact = build(:contact,
                    organization_id: organization.id,
                    country_id: country.id)

    viewer_page = Page.new
    viewer_page.visit
    viewer_page.fill_in_contact(contact)
    viewer_page.submit

    assert page.has_content?(I18n.t("organization.requested_to_join")), validation_errors + success_message

    email = ActionMailer::Base.deliveries.last
    link = email.body.to_s.scan(/\/academy\/viewers\/.+\/accept/).first

    visit link
    assert page.has_content? "The contact has been created"

    welcome_email = ActionMailer::Base.deliveries.last
    assert_equal "Welcome to the UN Global Compact Academy", welcome_email.subject
    assert_match(/reset_password_token=[A-Za-z\d]/, welcome_email.text_part.body.to_s)

    assert_no_difference -> { ActionMailer::Base.deliveries.size } do
      visit link
    end

    assert page.has_content? "The contact has been created"
  end

  test "accept new academy viewer for whitelisted organizations" do
    organization = create(:organization, id: Academy::Viewer::WHITELIST.first)
    country = create(:country)
    contact = build(:contact,
                    organization_id: organization.id,
                    country_id: country.id)

    viewer_page = Page.new
    viewer_page.visit
    viewer_page.fill_in_contact(contact)
    viewer_page.submit

    assert page.has_content?(I18n.t("organization.successfully_created_contact")), validation_errors + success_message

    welcome_email = ActionMailer::Base.deliveries.last
    assert_equal "Welcome to the UN Global Compact Academy", welcome_email.subject
    assert_match(/reset_password_token=[A-Za-z\d]/, welcome_email.text_part.body.to_s)
  end

  test "accept request to claim an existing contact" do
    organization = create(:organization)
    country = create(:country)
    contact = create(:contact,
                    organization_id: organization.id,
                    country_id: country.id,
                    username: nil,
                    encrypted_password: nil)

    viewer_page = Page.new
    viewer_page.visit
    viewer_page.fill_in_contact(contact)
    viewer_page.fill_in_username("foobar")
    viewer_page.submit

    assert page.has_content?(I18n.t("organization.requested_to_join")), validation_errors + success_message

    email = ActionMailer::Base.deliveries.last
    link = email.body.to_s.scan(/\/academy\/viewers\/.+\/accept/).first
    visit link

    reset_email = ActionMailer::Base.deliveries.last
    assert_equal "United Nations Global Compact - Reset Password", reset_email.subject

    assert_no_difference -> { ActionMailer::Base.deliveries.size } do
      visit link
    end
  end

  test "allow contacts from whitelisted organizations to claim accounts" do
    organization = create(:organization, id: Academy::Viewer::WHITELIST.first)

    country = create(:country)
    contact = create(:contact,
                     organization_id: organization.id,
                     country_id: country.id,
                     username: nil,
                     encrypted_password: nil)

    viewer_page = Page.new
    viewer_page.visit
    viewer_page.fill_in_contact(contact)
    viewer_page.fill_in_username("foobar")
    viewer_page.submit

    assert page.has_content?(I18n.t("organization.successfully_claimed_contact")), validation_errors + success_message

    email = ActionMailer::Base.deliveries.last
    assert_equal "United Nations Global Compact - Reset Password", email.subject
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

  def success_message
    find(".success-message span")&.text
  end

  def validation_errors
    all(".errors-list li").map(&:text).to_sentence
  end

  class Page
    include Capybara::DSL
    include Rails.application.routes.url_helpers

    def fill_in_organization_name(value) fill_in "Organization name", with: value; end
    def fill_in_prefix(value) fill_in "Prefix", with: value; end
    def fill_in_first_name(value) fill_in "First name", with: value; end
    def fill_in_middle_name(value) fill_in "Middle name", with: value; end
    def fill_in_last_name(value) fill_in "Last name", with: value; end
    def fill_in_job_title(value) fill_in "Job title", with: value; end
    def fill_in_email(value) fill_in "Email", with: value; end
    def fill_in_phone(value) fill_in "Phone", with: value; end
    def fill_in_address(value) fill_in "Postal address", with: value; end
    def fill_in_address_cont(value) fill_in "Address cont.", with: value; end
    def fill_in_city(value) fill_in "City", with: value; end
    def fill_in_state(value) fill_in "State/Province", with: value; end
    def fill_in_country_name(value) fill_in "Country", with: value; end
    def fill_in_postal_code(value) fill_in "ZIP/Code", with: value; end
    def fill_in_username(value) fill_in "Username", with: value; end
    def submit() click_on("Add contact"); end
    def visit() super(new_academy_viewer_path); end

    def fill_in_contact(contact)
      fill_in_organization_name(contact.organization.name)
      fill_in_prefix(contact.prefix)
      fill_in_first_name(contact.first_name)
      fill_in_middle_name(contact.middle_name)
      fill_in_last_name(contact.last_name)
      fill_in_job_title(contact.job_title)
      fill_in_email(contact.email)
      fill_in_phone(contact.phone)
      fill_in_address(contact.address)
      fill_in_address_cont(contact.address_more)
      fill_in_city(contact.city)
      fill_in_state(contact.state)
      fill_in_country_name(contact.country.name)
      fill_in_postal_code(contact.postal_code)
      fill_in_username(contact.username)
    end
  end

end
