require 'test_helper'

class Admin::ReportsControllerTest < ActionController::TestCase

  context "given a staff user" do
    setup do
      @staff_user = create_staff_user
      sign_in @staff_user
    end

    should "get the index page" do
      get :index, {}
      assert_response :success
    end

    should "get the approved logo request report" do
      get :approved_logo_requests, {}
      assert_response :success
      assert_template 'approved_logo_requests'
    end

    should "get the approved logo request report as xls" do
      get :approved_logo_requests, {:format => 'xls'}
      assert_response :success
      assert_excel_content_type
    end

    should "get the listed companies report" do
      get :listed_companies, {}
      assert_response :success
      assert_template 'listed_companies'
    end

    should "get the listed companies report as xls" do
      get :listed_companies, {:format => 'xls'}
      assert_response :success
      assert_excel_content_type
    end

    # should "get the networks report" do
    #      create_country
    #      get :networks, {}
    #      assert_response :success
    #      assert_template 'networks'
    #    end
    #
    #    should "get the networks report as xls" do
    #      create_country
    #      get :networks, {:format => 'xls'}
    #      assert_response :success
    #      assert_equal @response.headers['Content-Type'], xls_mime_type
    #    end

    should "get the foundation pledges report" do
      get :foundation_pledges, {}
      assert_response :success
      assert_template 'foundation_pledges'
    end

    should "get the foundation pledges report as xls" do
      get :foundation_pledges, {:format => 'xls'}
      assert_response :success
      assert_excel_content_type
    end

    should "get the participant breakdown report" do
      get :participant_breakdown, {}
      assert_response :success
      assert_template 'participant_breakdown'
    end

    should "get the participant breakdown report as xls" do
      get :participant_breakdown, {:format => 'xls'}
      assert_response :success
      assert_excel_content_type
    end

    should "get the contacts for mail merge report" do
      get :contacts_mail_merge, {}
      assert_response :success
      assert_template 'contacts_mail_merge'
    end

    should "get the contacts for mail merge report as xls" do
      get :contacts_mail_merge, {:format => 'xls'}
      assert_response :success
      assert_excel_content_type
    end

    should "get the local networks contacts report" do
      get :local_networks_contacts, {}
      assert_response :success
      assert_template 'local_networks_contacts'
    end

    should "get the local networks contacts report as xls" do
      get :local_networks_contacts, {:format => 'xls'}
      assert_response :success
      assert_excel_content_type
    end

    should "get the cop report" do
      get :all_cops, {}
      assert_response :success
      assert_template 'all_cops'
    end

    should "get the cop as xls" do
      get :all_cops, {:format => 'xls'}
      assert_response :success
      assert_excel_content_type
    end

    should "get the due diligence reviews report as xls" do
      get :due_diligence_reviews, {:format => 'xls'}
      assert_response :success
      assert_excel_content_type
    end

    context "given the initiatives report" do
      setup do
        @organization       = create(:organization)
        @organization2      = create(:organization)
        @climate_initiative = Initiative.find_by_filter(:climate) || create(:initiative, name: Initiative::FILTER_TYPES[:climate])
        @water_initiative   = Initiative.find_by_filter(:water_mandate) || create(:initiative, name: Initiative::FILTER_TYPES[:water_mandate])
        @climate_initiative.signings.create [ { :signatory => @organization },
                                             { :signatory => @organization2 } ]
      end

      should "task" do
        get :initiative_organizations, { :initiatives => [@climate_initiative.id] }
        assert_not_nil assigns(:report)
        assert_not_nil assigns(:selected_initiatives)
      end

    end

  end

  def assert_excel_content_type
    assert_equal 'application/vnd.ms-excel; charset=utf-8', @response.headers['Content-Type']
  end

end
