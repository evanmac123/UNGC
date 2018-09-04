require "test_helper"

class Admin::ActionPlatform::SubscriptionsControllerTest < ActionController::TestCase

  context "participation level for an Organization" do
    should 'allow Participant' do
      # Given a contact that is not from an organization is signed in
      contact = create(:contact)
      create_and_sign_in_to_organization(organization_type: OrganizationType.company,
                                         level_of_participation: :participant_level)

      # when we try to visit the form
      get :new

      assert_equal @response.response_code, 200, "Expected participation level participant to succeed"
    end

    should 'not allow Signatory' do
      # Given a contact that is not from an organization is signed in
      contact = create(:contact)
      create_and_sign_in_to_organization(organization_type: OrganizationType.company,
                                         level_of_participation: :signatory_level)

      # when we try to visit the form
      get :new

      # Then we are redirect away with an error
      assert_redirected_to dashboard_url, "expected signatory_level to fail"
      msg = I18n.t("notice.must_be_a_participant_to_choose_action_platforms")
      assert_equal msg, flash[:error]
    end
  end

  private


  def create_and_sign_in_to_organization(params = {})
    network = create(:local_network)
    country = create(:country, local_network: network)

    organization = create(:business, params.reverse_merge(
      country: country,
      cop_due_on: 3.months.from_now
    ))
    contact = create(:contact_point, :financial_contact, organization: organization)
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
