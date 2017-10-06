require "test_helper"

class Admin::LevelOfParticipationsControllerTest < ActionController::TestCase

  test "#new renders the form" do
    organization, _ = create_and_sign_in_to_organization
    get :new, organization_id: organization

    assert_response :success
    form = assigns(:form)
    assert_not_nil form
  end

  test "create with valid attributes updates the organization" do
    organization, contact = create_and_sign_in_to_organization(
      level_of_participation: nil)

    params = valid_params(
      level_of_participation: "signatory_level",
      contact_point_id: contact.id)

    post(:create, organization_id: organization,
      level_of_participation: params)

    form = assigns(:form)
    assert_not_nil form
    assert form.persisted?, form.errors.full_messages
    assert_redirected_to dashboard_url

    assert_equal I18n.t("level_of_participation.success"), flash[:notice]

    assert_equal "signatory_level", organization.reload.level_of_participation
  end

  test "#create re-renders the form with invalid attributes" do
    organization, _ = create_and_sign_in_to_organization

    post :create, organization_id: organization,
      level_of_participation: {
      financial_contact: { fax: "123-456-7890" }
    }

    assert_response :success
    form = assigns(:form)
    assert_not_nil form
  end

  test "financial contact params are pre-filled" do
    organization, contact = create_and_sign_in_to_organization

    get :new, organization_id: organization

    assert_select contact_field("prefix"), contact.prefix
    assert_select contact_field("first_name"), contact.first_name
    assert_select contact_field("middle_name"), contact.middle_name
    assert_select contact_field("last_name"), contact.last_name
    assert_select contact_field("job_title"), contact.job_title
    assert_select contact_field("email"), contact.email
    assert_select contact_field("phone"), contact.phone
    assert_select contact_field("fax"), contact.fax
    assert_select contact_field("address"), contact.address
    assert_select contact_field("address_more"), contact.address_more
    assert_select contact_field("city"), contact.city
    assert_select contact_field("state"), contact.state
    assert_select contact_field("postal_code"), contact.postal_code
    assert_select contact_field("country_id"), contact.country_id
  end

  private

  def contact_field(field)
    "input[name='level_of_participation[financial_contact][#{field}]'][value=?]"
  end

  def create_and_sign_in_to_organization(params = {})
    network = create(:local_network)
    country = create(:country, local_network: network)

    organization = create(:business, params.reverse_merge(
      country: country,
      cop_due_on: 3.months.from_now
    ))
    contact = create(:contact,
      organization: organization,
      roles: [Role.financial_contact])
    sign_in contact
    [organization, contact]
  end

  def valid_params(params = {})
    params.reverse_merge(
      level_of_participation: "participant_level",
      is_subsidiary: false,
      annual_revenue: 500_000,
      confirm_financial_contact_info: true,
      confirm_submission: true,
      invoice_date: 3.months.from_now,
      financial_contact: {
        prefix: "Mr",
        first_name: "Ben",
        last_name: "Moss",
        email: "ben@example.com",
        job_title: "Developer",
        address: "123 Green St.",
        city: "Toronto",
        country_id: create(:country).id,
        phone: "123-456-7890"
      }
    )
  end

end
