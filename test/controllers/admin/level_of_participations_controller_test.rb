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

  test "must be from an organization" do
    # Given a contact that is not from an organization is signed in
    contact = create(:contact)
    assert_not contact.from_organization?, "should not be from an organization"
    sign_in contact

    # when we try to visit the form
    get :new

    # Then we are redirect away with an error
    assert_redirected_to dashboard_url
    msg = I18n.t("notice.must_be_from_participation_to_choose_level_of_participation")
    assert_equal msg, flash[:error]
  end

  test "accepts Company, SME and Microenterprise" do
    valid_types = [OrganizationType.company, OrganizationType.sme, OrganizationType.micro_enterprise]
    valid_types.each do |org_type|
      create_and_sign_in_to_organization(organization_type: org_type)

      # when we try to visit the form
      get :new

      assert_equal @response.response_code, 200, "Expected org type #{org_type.name} to succeed"
    end
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
