class Organization::LevelOfParticipationFormTest < ActiveSupport::TestCase

  # Validations
  test "organization must be present" do
    form = build_form(
      organization: nil)
    assert_includes_error form, "Organization can't be blank"
  end

  test "level_of_participation must be present" do
    form = build_form(level_of_participation: nil)
    assert_includes_error form, "Level of participation must be given"
  end

  test "primary contact point must be present" do
    form = build_form(contact_point_id: nil)
    assert_includes_error form, "Contact point can't be blank"
  end

  test "subsidiary question must be answered" do
    form = build_form(is_subsidiary: nil)
    assert_includes_error form, "Is subsidiary must be indicated"
  end

  test "parent company must be present in the case of a subsidiary" do
    form = build_form(
      is_subsidiary: true, parent_company_id: nil)
    assert_includes_error form, "Parent company can't be blank"
  end

  test "parent company must be blank when it's not a subsidiary" do
    form = build_form(
      is_subsidiary: false, parent_company_id: nil)
    assert form.valid?, form.errors.full_messages
  end

  test "annual revenue must be given" do
    form = build_form(annual_revenue: nil)
    assert_includes_error form, "Annual revenue must be greater than 0 and less than $US 92,000,000,000,000,000"
  end

  test "annual revenue must be a positive amount" do
    form = build_form(annual_revenue: -123)
    assert_includes_error form, "Annual revenue must be greater than 0 and less than $US 92,000,000,000,000,000"
  end

  test "financial contact info must be confirmed" do
    form = build_form(
      confirm_financial_contact_info: nil)
    assert_includes_error form, "Confirm financial contact info must be accepted"

    form = build_form(
      confirm_financial_contact_info: "false")
    assert_includes_error form, "Confirm financial contact info must be accepted"
  end

  test "the submission as a whole must be confirmed" do
    form = build_form(
      confirm_submission: nil)
    assert_includes_error form, "Confirm submission must be accepted"

    form = build_form(
      confirm_submission: "0")
    assert_includes_error form, "Confirm submission must be accepted"
  end

  test "invoice_date is required when the local network requires it" do
    local_network = create(:local_network, invoice_options_available: "yes")
    country = create(:country, local_network: local_network)
    organization = create(:organization, country: country)

    form = build_form(
      organization: organization,
      level_of_participation: "participant_level",
      invoice_date: nil)
    assert_includes_error form, "Invoice date can't be blank"
  end

  test "invoice_date is not required when the invoicing policy doesn't require it" do
    form = build_form(invoice_date: nil)

    policy = mock("invoicing_policy")
    policy.expects(:validate).with(form).returns(:nil)
    Organization::InvoicingPolicy.stubs(:new).returns(policy)

    assert form.valid?, form.errors.full_messages
  end

  test "invoice_date is required when the incoming annual revenue is over the threshold" do
    # from an actual bug
    threshold = Organization::InvoicingPolicy::GlobalLocal::THRESHOLD
    low_revenue = threshold - Money.from_amount(1)
    high_revenue = threshold + Money.from_amount(1)

    # Given an organization without revenue under the threshold
    organization = create(:organization, precise_revenue: low_revenue)

    # When the create a form for the organization
    initial_form = Organization::LevelOfParticipationForm.from(organization)
    initial_form = build_form(invoice_date: nil,
      organization: organization,
      annual_revenue: nil)

    # When they submit a form with annual revenue that crosses the threshold
    form = build_form(invoice_date: nil,
      organization: organization,
      annual_revenue: high_revenue)

    # Then the form is invalid
    assert_includes_error form, "Invoice date can't be blank"
  end

  test "lead submissions must accept the platform removal terms" do
    form = build_form(level_of_participation: "lead_level", accept_platform_removal: nil)

    assert_not form.save, "form should not be valid"
    assert_includes_error form, "Accept platform removal policy must be accepted"
  end

  test "participant and signatory levels don't have to accept the platform removal terms" do
    form = build_form(level_of_participation: "signatory_level", accept_platform_removal: nil)
    assert form.save, form.errors.full_messages

    form = build_form(level_of_participation: "participant_level", accept_platform_removal: nil)
    assert form.save, form.errors.full_messages
  end

  test "sets organization level_of_participation" do
    form = build_form(level_of_participation: "participant_level")
    organization = form.organization
    organization.level_of_participation = nil

    assert form.save, "failed to submit form"
    assert_equal "participant_level", organization.reload.level_of_participation
  end

  test "sets precise revenue" do
    form = build_form(
      annual_revenue: "$1,000,000")
    organization = form.organization

    assert form.save, form.errors.full_messages
    assert_equal 1_000_000_00, organization.reload.precise_revenue_cents
  end

  test "sets invoice date" do
    date = Time.current.to_date
    form = build_form(invoice_date: date)

    assert form.save, form.errors.full_messages
    assert_equal date, form.organization.invoice_date
  end

  test "sets parent company" do
    parent_company = create(:business)
    form = build_form(
      parent_company_id: parent_company.id)

    assert form.save, form.errors.full_messages
    assert_equal parent_company.name, form.organization.parent_company.name
  end

  test "supports persisted?" do
    form = build_form
    refute form.persisted?
    assert form.save
    assert form.persisted?
  end

  test "only show contacts that are able to login as candidates for contact points" do
    # Given a contact from an organization that can't login
    organization = create(:organization)
    ceo = create(:contact,
      first_name: "Ceo",
      username: nil,
      password: nil,
      organization: organization,
      roles: [Role.ceo])

    # And a contact point who can login
    cp = create(:contact,
      first_name: "Cp",
      username: "alice123",
      password: "Passw0rd",
      organization: organization,
      roles: [Role.contact_point])

    # When we ask for the list of contacts
    form = Organization::LevelOfParticipationForm.new(organization: organization)
    contact_names = form.organization_contacts.map(&:first)

    # Then we see that the contact with a valid login is there
    assert_includes contact_names, cp.name

    # And we see that the contact without is not
    assert_not_includes contact_names, ceo.name
  end

  test "When a company marks itself as it's own parent company, it is silently ignored" do
    organization = create(:organization, :participant_level, :has_participant_manager, country: create(:country, :with_local_network))
    form = build_form(organization: organization, parent_company_id: organization.id)

    assert form.save, form.errors.full_messages

    assert_nil organization.reload.parent_company_id
  end

  test "action platforms selected must be valid" do
    platform = create(:action_platform_platform)

    form = build_form(
      level_of_participation: "lead_level",
      subscriptions: {
        platform.id => {
          selected: true,
          platform_id: platform.id,
          contact_id: nil
        }
      }
    )

    assert_includes_error form, "Subscriptions a contact must be provided for each Action Platform selected"
  end

  test "selecting lead puts the organization in the participant tier" do
    form = build_form(
      level_of_participation: "lead_level",
      accept_platform_removal: true,
    )

    assert form.save, form.errors.full_messages
    organization = form.organization.reload
    assert_equal "participant_level", organization.level_of_participation
  end

  test "selecting a level of participation sends an email" do
    # Given an organization and a network contact from the same network
    network = create(:local_network)
    country = create(:country, local_network: network)
    create(:staff_contact, :network_focal_point, local_network: network)
    organization = create(:organization,
      level_of_participation: nil,
      country: country)

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      # When they choose a level of participation
      form = build_form(organization: organization, level_of_participation: :signatory_level)
      assert form.save, form.errors.full_messages
    end

    # Then the engagement tier email is sent
    email = OrganizationMailer.deliveries.last
    assert_not_nil email
    assert_match(/Engagement Tier 'Signatory Level' Chosen/, email.subject)
  end

  private

  def build_form(params = {})
    organization = params.fetch :organization do
      create(:organization, :participant_level, :has_participant_manager, country: create(:country, :with_local_network))
    end

    contact_point_id = params.fetch :contact_point_id do
      create(:contact, organization: organization,
        roles: [Role.contact_point]).id
    end

    Organization::LevelOfParticipationForm.new(params.reverse_merge(
      level_of_participation: "participant_level",
      is_subsidiary: false,
      annual_revenue: 50_000,
      confirm_financial_contact_info: true,
      confirm_submission: true,
      contact_point_id: contact_point_id,
      organization: organization,
      financial_contact_id: contact_point_id,
      financial_contact_action: "choose",
      invoice_date: 3.months.from_now.to_date,
    ))
  end

  def contact_attrs(contact)
    financial_contact = Organization::LevelOfParticipationForm::FinancialContact.from(contact)
    financial_contact.to_h.transform_values do |v|
      if v.nil?
        ""
      else
        v
      end
    end
  end

end
