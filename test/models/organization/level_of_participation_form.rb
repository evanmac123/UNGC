class Organization::LevelOfParticipationFormTest < ActiveSupport::TestCase

  # Validations
  test "organization must be present" do
    form = build_form(
      organization: nil)
    assert_includes_error form, "Organization can't be blank"
  end

  test "level_of_participation must be present" do
    form = build_form(
      level_of_participation: nil)
    assert_includes_error form, "Level of participation can't be blank"
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
    form = build_form(
      annual_revenue: nil)
    assert_includes_error form, "Annual revenue must be greater than 0"
  end

  test "annual revenue must be a positive amount" do
    form = build_form(
      annual_revenue: -123)
    assert_includes_error form, "Annual revenue must be greater than 0"
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
    form.invoicing_policy = stub(invoicing_required?: false)
    assert form.valid?, form.errors.full_messages
  end

  test "invoice_date is required when the incoming annual revenue is over the threshold" do
    # from an actual bug
    low_revenue = Organization::InvoicingPolicy::THRESHOLD - Money.from_amount(1)
    high_revenue = Organization::InvoicingPolicy::THRESHOLD + Money.from_amount(1)

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
    date = Date.new(2018, 1, 1)
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

  test "a new financial contact is created when one doesn't exist" do
    organization = create(:organization)
    assert_empty organization.contacts

    c = build(:contact)
    contact_attributes = contact_attrs(c)

    form = build_form(organization: organization, financial_contact: contact_attributes)

    assert form.save, form.errors.full_messages
    names = organization.reload.
      contacts.
      financial_contacts.
      map(&:name)

    assert_contains names, c.name
  end

  test "updates the financial contact if it already exists" do
    organization = create(:organization)
    c = create(:contact,
      organization: organization,
      middle_name: "Old",
      roles: [Role.financial_contact]
    )

    c.middle_name = "Changed"
    financial_contact = contact_attrs(c)

    form = build_form(
      organization: organization,
      financial_contact: financial_contact
    )

    assert form.save, form.errors.full_messages
    financial_contact = form.organization.contacts.financial_contacts.first

    assert_not_nil financial_contact
    assert_equal "Changed", financial_contact.middle_name
  end

  test "duplicate email" do
    # Given a contact
    email = "alice@example.com"
    create(:contact, email: email)

    # When we try to create a new financial contact with the same email
    # we get a validation error
    c = build(:contact, email: email)
    financial_contact = contact_attrs(c)
    assert_equal email, financial_contact.fetch(:email)

    form = build_form(financial_contact: financial_contact)
    form.save
    assert_includes_error form, "Email has already been taken"
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
    organization = create(:organization)
    form = build_form(organization: organization, parent_company_id: organization.id)

    assert form.save, form.errors.full_messages

    assert_nil organization.reload.parent_company_id
  end

  private

  def build_form(params = {})
    organization = params.fetch :organization do
      create(:organization)
    end

    contact_point_id = params.fetch :contact_point_id do
      create(:contact, organization: organization,
        roles: [Role.contact_point]).id
    end

    financial_contact = params.fetch :financial_contact do
      c = build(:contact, organization: organization,
        roles: [Role.financial_contact])
      contact_attrs(c)
    end

    Organization::LevelOfParticipationForm.new(params.reverse_merge(
      level_of_participation: "participant_level",
      is_subsidiary: false,
      annual_revenue: 50_000,
      confirm_financial_contact_info: true,
      confirm_submission: true,
      contact_point_id: contact_point_id,
      organization: organization,
      financial_contact: financial_contact,
      invoice_date: 3.months.from_now,
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