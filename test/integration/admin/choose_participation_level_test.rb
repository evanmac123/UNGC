require "test_helper"

class Admin::ChooseParticipationLevelTest < ActionDispatch::IntegrationTest

  test "a legacy organization chooses a participation level" do
    # Given a network which requires invoicing
    network = create_invoicing_network

    # And an organization from that network
    organization = create_organization(network)

    # With an unassociated parent company
    parent_organization = create(:business)

    # And a contact point
    contact = create_contact_point(organization)

    # And a financial contact
    create_financial_contact(organization)

    # When an user visits the link provided in their email
    form = TestPage::ChooseLevelOfParticipation.new
    visit form.path

    # Then they must login
    login = TestPage::Login.new
    login.visit
    login.fill_in_username(contact.username)
    login.fill_in_password(contact.password)
    login.submit

    # (Simulate being redirected after successful login)
    form.visit

    # And they select a level of participation
    form.select_level_of_participation("signatory")

    # And confirm the primary contact point
    form.confirm_contact_point(contact)

    # And indicate that the organization is a subsidiary
    form.is_subsidiary = true

    # Fill in the subsidiary company name
    form.subsidiary_of(parent_organization)

    # Enter the annual revenue amount
    form.annual_revenue = "123,456,567"

    # Update the financial contact's info
    form.contact_middle_name = "Changed"

    # Confirm the financial contact info is correct
    form.confirm_financial_contact_info

    # Set the invoice date
    form.invoice_on_cop_due_date_of(organization)

    # Confirm the submission
    form.confirm_submission

    # When we submit
    form.submit

    # Then we expect that it will be successful
    assert_equal dashboard_path, current_path
    page.has_content? I18n.t("level_of_participation.success")
  end

  test "Changes to revenue that affect the invoicing policy are validated" do
    # From an actual bug.

    # Given a network with the global-local revenue sharing model
    # And an organization from that network
    # And a contact point from that organization that we're logged in as
    # And a financial contact from that organization
    network = create_global_local_network
    organization = create_organization(network)
    contact = create_contact_point(organization)
    login_as contact
    create_financial_contact(organization)

    # When they fill out the form without an invoice_date
    # (which they cannot yet see on the form)
    form = TestPage::ChooseLevelOfParticipation.new
    form.visit
    form.select_level_of_participation("signatory")
    form.confirm_contact_point(contact)
    form.is_subsidiary = false
    form.annual_revenue = "9,123,456,567"
    form.confirm_financial_contact_info
    form.confirm_submission
    form.submit

    # Then we expect that it will NOT be successful
    assert_equal admin_choose_level_of_participation_path, current_path

    # Because the invoice date is now required
    assert form.has_validation_error?("Invoice date can't be blank")

    # When they fill it in and re-submit
    form.invoice_me_now
    form.submit

    # Then we expect that it will be successful
    assert_equal dashboard_path, current_path, validation_errors
    form.has_content? I18n.t("level_of_participation.success")
  end

  private

  def create_invoicing_network
    create(:local_network,
      invoice_options_available: "yes"
    )
  end

  def create_global_local_network
    create(:local_network,
      invoice_options_available: "no",
      business_model: "global_local")
  end

  def create_organization(local_network)
    create(:business,
      level_of_participation: nil,
      sector: create(:sector),
      listing_status: create(:listing_status),
      country: create(:country, local_network: local_network),
      cop_due_on: 3.months.from_now
    )
  end

  def create_contact_point(organization)
    create(:contact,
      organization: organization,
      password: "Passw0rd",
      roles: [Role.contact_point])
  end

  def create_financial_contact(organization)
    create(:contact,
      organization: organization,
      roles: [Role.financial_contact])
  end

  def find_level_of_participation
    find(:xpath, '//dt[text()="Level of Participation"]/following-sibling::dd[1]').text
  end

  def validation_errors
    all("#errorExplanation li").map(&:text)
  end

end
