require "test_helper"

class Admin::ChooseParticipationLevelTest < ActionDispatch::IntegrationTest

  test "a legacy organization chooses a participation level" do
    # Given a contact from an existing organization
    network = create(:local_network, invoice_options_available: "yes")
    organization = create(:business,
      level_of_participation: nil,
      sector: create(:sector),
      listing_status: create(:listing_status),
      country: create(:country, local_network: network),
      cop_due_on: 3.months.from_now)

    parent_organization = create(:business)

    contact = create(:contact,
      organization: organization,
      password: "Passw0rd",
      roles: [Role.contact_point])

    create(:contact,
      organization: organization,
      roles: [Role.financial_contact])

    # When an user visits the link provided in their email
    visit admin_choose_level_of_participation_path

    # Then they are asked to login
    assert_equal new_contact_session_path, current_path

    # When they provide valid credentials
    fill_in "Username", with: contact.username
    fill_in "Password", with: contact.password
    click_on "Login"

    # (Simulate being redirected after successful login)
    visit admin_choose_level_of_participation_path

    # And they select a level of participation
    choose "SIGNATORY"

    # And confirm the primary contact point
    select contact.name, from: I18n.t("level_of_participation.confirm_primary_contact_point")

    # And indicate that the organization is a subsidiary
    choose("level_of_participation[is_subsidiary]", option: true)

    # Fill in the subsidiary company name
    fill_in "level_of_participation_parent_company_name", with: parent_organization.name

    find(:xpath, "//input[@id='level_of_participation_parent_company_id']").set(parent_organization.id)

    # Enter the annual revenue amount
    fill_in I18n.t("level_of_participation.confirm_annual_revenue"), with: "123,456,567"

    # Update the financial contact's info
    fill_in "Middle name", with: "Changed"

    # Confirm the financial contact info is correct
    check I18n.t("level_of_participation.confirm_financial_contact_info")

    # Set the invoice date
    choose I18n.t("level_of_participation.invoice_on_next_cop_due_date",
      cop_due_on: organization.cop_due_on)
    fill_in "level_of_participation[invoice_date]", with: today

    # Confirm the submission
    check I18n.t("level_of_participation.confirm_submission")

    # When we submit
    click_on "Confirm"

    # Then we expect that it will be successful
    assert_equal dashboard_path, current_path
    page.has_content? I18n.t("level_of_participation.success")
  end

  test "an actual bug" do
    # Given a network with the global-local revenue sharing model
    network = create(:local_network,
      invoice_options_available: "no",
      business_model: "global_local")

    # And an organization from that network
    organization = create(:business,
      level_of_participation: nil,
      sector: create(:sector),
      listing_status: create(:listing_status),
      country: create(:country, local_network: network),
      precise_revenue: nil,
      cop_due_on: 3.months.from_now)

    # And a contact point from that organization that we're logged in as
    contact = create(:contact,
      organization: organization,
      password: "Passw0rd",
      roles: [Role.contact_point])
    login_as contact

    # And a financial contact from that organization
    create(:contact,
      organization: organization,
      roles: [Role.financial_contact])

    # When an user visits the link provided in their email
    visit admin_choose_level_of_participation_path

    # And they select a level of participation
    choose "SIGNATORY"

    # And confirm the primary contact point
    select contact.name, from: I18n.t("level_of_participation.confirm_primary_contact_point")

    # And indicate that the organization is a subsidiary
    choose("level_of_participation[is_subsidiary]", option: false)

    # Enter the annual revenue amount
    fill_in I18n.t("level_of_participation.confirm_annual_revenue"), with: "9,123,456,567"

    # Confirm the financial contact info is correct
    check I18n.t("level_of_participation.confirm_financial_contact_info")

    # Confirm the submission
    check I18n.t("level_of_participation.confirm_submission")

    # When we submit
    click_on "Confirm"

    # Then we expect that it will NOT be successful
    assert_equal admin_choose_level_of_participation_path, current_path

    # Because the invoice date is missing
    page.has_content? "Invoice date can't be blank"

    # And they should be able to fill it in now
    choose "Invoice me now"
    fill_in "level_of_participation[invoice_date]", with: today

    # When we submit
    click_on "Confirm"

    # Then we expect that it will be successful
    assert_equal dashboard_path, current_path, validation_errors

    page.has_content? I18n.t("level_of_participation.success")
  end

  private

  def find_level_of_participation
    find(:xpath, '//dt[text()="Level of Participation"]/following-sibling::dd[1]').text
  end

  def validation_errors
    all("#errorExplanation li").map(&:text)
  end

  def today
    Time.zone.now.to_date.strftime("%d-%m-%Y")
  end

end
