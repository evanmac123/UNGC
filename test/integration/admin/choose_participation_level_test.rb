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
    form.select_level_of_participation("SIGNATORY")

    # And confirm the primary contact point
    form.confirm_contact_point(contact)

    # And indicate that the organization is a subsidiary
    form.is_subsidiary = true

    # Fill in the subsidiary company name
    form.subsidiary_of(parent_organization)

    # Enter the annual revenue amount
    form.annual_revenue = "123,456,567"

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
    form.select_level_of_participation("SIGNATORY")
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

  test "When there is no financial contact, an existing contact can be selected" do
    organization = create_organization
    contact_point = create_contact_point(organization)
    assert_not_includes roles(contact_point), "Financial Contact"
    login_as contact_point

    form = TestPage::ChooseLevelOfParticipation.new
    form.visit

    # When the form is filled out
    form.select_level_of_participation("PARTICIPANT")
    form.annual_revenue = "$123,456.78"
    form.confirm_contact_point(contact_point)
    form.confirm_financial_contact_info
    form.invoice_me_now
    form.confirm_submission

    # And the contact point is given the financial contact role
    form.assign_financial_contact_role_to(contact_point)
    form.submit

    # Then the submission should be valid
    assert_empty form.validation_errors

    # And the contact should have the financial contact role
    assert_includes roles(contact_point), "Financial Contact"
  end

  test "When there is no financial contact, one can be created" do
    organization = create_organization
    contact_point = create_contact_point(organization)
    assert_not_includes roles(contact_point), "Financial Contact"
    login_as contact_point

    form = TestPage::ChooseLevelOfParticipation.new
    form.visit

    # When the form is filled out
    form.select_level_of_participation("PARTICIPANT")
    form.annual_revenue = "$123,456.78"
    form.confirm_contact_point(contact_point)
    form.confirm_financial_contact_info
    form.invoice_me_now
    form.confirm_submission

    # And the contact point is given the financial contact role
    attributes = {
      prefix: "Mr.",
      first_name: "Bob",
      middle_name: "Norman",
      last_name: "Ross",
      job_title: "Painter",
      email: "bob@example.com",
      phone: "123-456-7890",
      address: "123 Happy Little Tree Lane",
      address_2: "Suite 123",
      city: "Daytona Beach",
      state: "California",
      country: organization.country.name,
    }

    form.create_financial_contact(attributes)
    form.submit

    # Then the submission should be valid
    assert_empty form.validation_errors

    # And there should be a new financial contact
    financial_contact = organization.contacts.financial_contacts.first
    assert_not_nil financial_contact, "Financial contact was not created"
    assert_equal "Bob Ross", financial_contact.name
  end

  test "When there is a financial contact, it is selected by default" do
    organization = create_organization
    contact_point = create_contact_point(organization)
    create_financial_contact(organization)
    login_as contact_point

    form = TestPage::ChooseLevelOfParticipation.new
    form.visit

    # When the form is filled out
    form.select_level_of_participation("PARTICIPANT")
    form.annual_revenue = "$123,456.78"
    form.confirm_contact_point(contact_point)
    form.confirm_financial_contact_info
    form.invoice_me_now
    form.confirm_submission

    # We are able to submit successfully as the existing
    # financial contact has been chosen and re-confirmed
    form.submit
    assert_empty form.validation_errors
  end

  test "ActionPlatform LEAD" do
    # Given 3 platforms, 2 we will subscribe to and 1 which will remain unsubscribbed to
    platform1, platform2, _platform3 = create_list(:action_platform_platform, 3)

    # And an organization from a network
    organization = create_organization()

    # With a contact point for the organization
    contact = create_contact_point(organization)

    # And a contact for the network
    create(:staff_contact, :network_focal_point,
      local_network: organization.local_network)

    # When we're logged in as the organization contact
    login_as(contact)

    form = TestPage::ChooseLevelOfParticipation.new
    visit form.path

    form.select_level_of_participation("PARTICIPANT + ACTION PLATFORMS & LEAD ELIGIBILITY")
    form.confirm_contact_point(contact)
    form.is_subsidiary = false
    form.annual_revenue = "123,456,567"
    form.assign_financial_contact_role_to(contact)
    form.confirm_financial_contact_info
    form.invoice_me_now
    form.confirm_submission
    form.accept_platform_removal

    # Select 2 action platforms
    form.signup_for_action_platform(platform1, contact)
    form.signup_for_action_platform(platform2, contact)

    # When we submit
    form.submit

    # Then we expect that it will be successful
    assert_empty form.validation_errors
    assert_equal dashboard_path, current_path
    page.has_content? I18n.t("level_of_participation.success")

    engagement_tier_email, ap_subscription_email = ActionMailer::Base.deliveries.last(2)

    # And that an email was sent to the network about the engagement tier
    assert_not_nil engagement_tier_email
    assert_equal "Engagement Tier 'Participant Level' Selected By: #{organization.name}",
      engagement_tier_email.subject

    # And one to the RM team about the Action Platform Subscriptions
    assert_not_nil ap_subscription_email
    assert_equal "Action Platform Order Received from #{organization.name}",
      ap_subscription_email.subject

    # And that there is a new AP order for the organization and financial contact
    assert_equal 1, organization.action_platform_orders.count
    order = organization.action_platform_orders.first
    assert_equal organization, order.organization
    assert_equal contact, order.financial_contact

    # And it should sign the contact up to the two platforms
    assert_equal 2, order.subscriptions.count
    assert_equal [contact.id, contact.id], order.subscriptions.map(&:contact_id)
    assert_equal [platform1.id, platform2.id], order.subscriptions.map(&:platform_id)
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

  def create_organization(local_network = nil)
    create(:business,
      level_of_participation: nil,
      sector: create(:sector),
      listing_status: create(:listing_status),
      country: create(:country, local_network: local_network || create(:local_network)),
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

  def roles(contact)
    contact.reload.roles.map(&:name)
  end

end
