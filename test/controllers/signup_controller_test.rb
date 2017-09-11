require 'test_helper'

class SignupControllerTest < ActionController::TestCase
  context "given an organization that wants to sign up" do
    setup do
      create(:container, path: '/participation/join/application', layout: :article)

      @country = create(:country)
      @listing_status = create(:listing_status)

      @signup_contact = {
        first_name: 'Michael',
        last_name: 'Smith',
        prefix: 'Mr',
        job_title: 'Job Title',
        phone: '+1 416 1234567',
        address: '123 Example Ave',
        city: 'Toronto',
        country_id: Country.first.id,
        email: 'michael@example.com',
        username: 'username',
        password: 'Passw0rd',
        role_ids: [Role.contact_point.id]
      }

      @signup_ceo = {
        first_name: 'CEO',
        last_name: 'Smith',
        prefix: 'Mr',
        job_title: 'CEO',
        phone: '+1 416 1234567',
        address: '123 Example Ave',
        city: 'Toronto',
        country_id: Country.first.id,
        email: 'smith@example.com',
        role_ids: [Role.ceo.id]
      }

      @financial_contact = {
        first_name: 'Michael',
        last_name: 'Smith',
        prefix: 'Mr',
        job_title: 'Accountant',
        phone: '+1 416 1234567',
        address: '123 Example Ave',
        city: 'Toronto',
        country_id: Country.first.id,
        email: 'michael@example.com',
        role_ids: [Role.financial_contact.id]
      }
    end

    should 'get index' do
      get :index
      assert_response :success
      assert_not_nil assigns(:page)
    end

    should "get the first step page" do
      get :step1, org_type: 'business'
      assert_response :success
    end

    should "get the second step page after posting organization details" do
      params = {
        name: 'ACME inc',
        employees: 500,
        url: 'http://www.example.com',
        country_id: @country.id,
        sector_id: Sector.last.id,
        listing_status_id: @listing_status.id,
        revenue: Organization::REVENUE_LEVELS.keys.first,
        level_of_participation: "signatory_level",
        is_tobacco: "true",
        is_landmine: "true",
        is_biological_weapons: "true",
        organization_type_id: OrganizationType.first.id
      }
      post :step2, organization: params
      assert_response :success
      assert_template 'step2'
    end

    should "be redirected to step 1 if data is not valid" do
      post :step2, organization: {name: 'ACME inc',
                                  url: 'http://www.example.com',
                                  organization_type_id: OrganizationType.sme}
      assert_redirected_to organization_step1_path({org_type: 'business'})
    end

    should "get the third step page after posting contact details" do
      post :step3, contact: @signup_contact
      assert_response :success
      assert_template 'step3'
    end

    # pledge form
    should "as a business should get the fourth step page after posting ceo contact details" do
      @local_network = create(:local_network, funding_model: 'collaborative')
      @country.local_network_id = @local_network.id

      @signup = BusinessOrganizationSignup.new
      @signup.set_organization_attributes({name: 'ACME inc',
                                           organization_type_id: OrganizationType.first.id,
                                           revenue: 2500})
      store_pending(@signup)

      post :step4, contact: @signup_ceo
      assert_response :success
      assert_template 'step4'
      # FIXME: correct pledge form is not being assigned in test
      # assert_equal 'pledge_form_collaborative', @signup.pledge_form_type
      # assert_template partial: '_pledge_form_collaborative', count: 1
      assert_select 'h2', 'Financial Commitment'
      # five possible pledge amounts and one opt-out
      assert_select 'table' do
        assert_select "input[type=radio]", 6
        assert_select 'label', 10
      end
    end

    # upload letter of commitment
    should "as a non-business the next_step for the ceo form should be step6" do
      @signup = NonBusinessOrganizationSignup.new
      @signup.set_organization_attributes({name: 'ACME inc',
                                           organization_type_id: OrganizationType.city.id})
      store_pending(@signup)

      post :step3, contact: @signup_contact
      assert_template 'step3'
      assert_equal organization_step6_path, assigns(:next_step)
    end

    should "as a business should get the fifth step page after selecting a contribution amount" do
      @signup = BusinessOrganizationSignup.new
      @signup.set_organization_attributes({name: 'ACME inc',
                                           organization_type_id: OrganizationType.sme.id,
                                           revenue: 2500})
      store_pending(@signup)

      post :step5, organization: {pledge_amount: 2000}
      assert_response :success
      assert_template 'step5'
      assert_select 'h2', 'Financial Contact'
    end

    should "as a business should get the sixth step page if they don't select a contribution amount" do
      @signup = BusinessOrganizationSignup.new
      @signup.set_organization_attributes({name: 'ACME inc',
                                           organization_type_id: OrganizationType.sme.id})
      store_pending(@signup)

      post :step5, organization: {pledge_amount: 0, no_pledge_reason: 'budget'}
      assert_redirected_to organization_step6_path
    end

    should "as a business should be redirected to 4 step page if they don't select a reason for not pledging" do
      @signup = BusinessOrganizationSignup.new
      @signup.set_organization_attributes({name: 'ACME inc',
                                           organization_type_id: OrganizationType.sme.id})
      store_pending(@signup)

      post :step5, organization: {pledge_amount: 0}
      assert_redirected_to organization_step4_path
    end

    should "get the sixth step page after posting ceo contact details" do
      @signup = BusinessOrganizationSignup.new
      @signup.set_organization_attributes({name: 'ACME inc',
                                           organization_type_id: OrganizationType.sme.id})
      store_pending(@signup)

      post :step6, contact: @signup_ceo
      assert_response :success
      assert_template 'step6'
    end

    should "as a non-business should get the sixth step page after posting ceo contact details" do
      @signup = NonBusinessOrganizationSignup.new
      @signup.set_organization_attributes({name: 'ACME inc',
                                           organization_type_id: OrganizationType.city.id})
      store_pending(@signup)

      post :step6, contact: @signup_ceo
      assert_response :success
      assert_template 'step6'
    end

    should "get the seventh step page after submitting letter of commitment" do
      @signup = NonBusinessOrganizationSignup.new
      @signup.set_organization_attributes(name: 'City University',
                                       organization_type_id: OrganizationType.academic.id,
                                       employees: 50,
                                       country_id: Country.first.id,
                                       legal_status: fixture_file_upload('files/untitled.pdf', 'application/pdf'))
      @signup.set_registration_attributes(number: "test",
                                        date: "12/3/2013",
                                        place: "bla",
                                        authority: "bla",
                                        mission_statement: "A")
      @signup.set_primary_contact_attributes(@signup_contact)
      @signup.set_ceo_attributes(@signup_ceo)
      store_pending(@signup)

      assert_difference 'ActionMailer::Base.deliveries.size' do
        assert_difference 'Organization.count' do
          assert_difference 'Contact.count', 2 do
            post :step7, organization: {commitment_letter: fixture_file_upload('files/untitled.pdf', 'application/pdf')}
          end
        end
      end
      assert_response :success
      assert_template 'step7'
    end

    should "send an email to JCI if the applicant was a referral from their website" do
      @signup = NonBusinessOrganizationSignup.new
      @signup.set_organization_attributes(name: 'City University',
                                       organization_type_id: OrganizationType.first.id,
                                       employees: 50,
                                       country_id: Country.first.id,
                                       legal_status: fixture_file_upload('files/untitled.pdf', 'application/pdf'))
      @signup.set_registration_attributes(number: "test",
                                        date: "12/3/2013",
                                        place: "bla",
                                        authority: "bla",
                                        mission_statement: "A")
      @signup.set_primary_contact_attributes(@signup_contact)
      @signup.set_ceo_attributes(@signup_ceo)
      session[:is_jci_referral] = true
      store_pending(@signup)

      assert_difference 'ActionMailer::Base.deliveries.size', 2 do
        post :step7, organization: {commitment_letter: fixture_file_upload('files/untitled.pdf', 'application/pdf')}
      end
      assert_response :success
      assert_template 'step7'
    end

    should "see the PRME invitation on the seventh step page if they are an Academic organization" do
      @academic = OrganizationType.where(name: 'Academic').first
      @signup = NonBusinessOrganizationSignup.new
      @signup.set_organization_attributes(name: 'City University',
                                       organization_type_id: @academic.id,
                                       employees: 50,
                                       country_id: Country.first.id,
                                       legal_status: fixture_file_upload('files/untitled.pdf', 'application/pdf'))
      @signup.set_registration_attributes(number: "test",
                                        date: "12/3/2013",
                                        place: "bla",
                                        authority: "bla",
                                        mission_statement: "A")
      @signup.set_primary_contact_attributes(@signup_contact)
      @signup.set_ceo_attributes(@signup_ceo)
      store_pending(@signup)

      post :step7, organization: {commitment_letter: fixture_file_upload('files/untitled.pdf', 'application/pdf')}
      assert_response :success
      assert_template 'step7'
      assert_select 'div.prme'
    end
  end

  private

  def store_pending(signup)
    PendingSignup.new(session.id).store(signup)
  end

end
