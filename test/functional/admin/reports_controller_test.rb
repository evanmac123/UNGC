require 'test_helper'

class Admin::ReportsControllerTest < ActionController::TestCase
  context "given a staff user" do
    setup do
      @staff_user = create_staff_user
    end
    
    should "get the index page" do
      get :index, {}, as(@staff_user)
      assert_response :success
    end
    
    should "get the approved logo request report" do
      get :approved_logo_requests, {}, as(@staff_user)
      assert_response :success
      assert_template 'approved_logo_requests.html.haml'
    end

    should "get the approved logo request report as csv" do
      get :approved_logo_requests, {:format => 'csv'}, as(@staff_user)
      assert_response :success
      assert_equal @response.headers['Content-type'], 'application/ms-excel'
    end

    should "get the listed companies report" do
      get :listed_companies, {}, as(@staff_user)
      assert_response :success
      assert_template 'listed_companies.html.haml'
    end

    should "get the listed companies report as csv" do
      get :listed_companies, {:format => 'csv'}, as(@staff_user)
      assert_response :success
      assert_equal @response.headers['Content-type'], 'application/ms-excel'
    end

    should "get the companies without contacts report" do
      get :companies_without_contacts, {}, as(@staff_user)
      assert_response :success
      assert_template 'companies_without_contacts.html.haml'
    end

    should "get the companies without contacts report as csv" do
      get :companies_without_contacts, {:format => 'csv'}, as(@staff_user)
      assert_response :success
      assert_equal @response.headers['Content-type'], 'application/ms-excel'
    end
    
    should "get the networks report" do
      create_country
      get :networks, {}, as(@staff_user)
      assert_response :success
      assert_template 'networks.html.haml'
    end

    should "get the networks report as csv" do
      create_country
      get :networks, {:format => 'csv'}, as(@staff_user)
      assert_response :success
      assert_equal @response.headers['Content-type'], 'application/ms-excel'
    end

    should "get the foundation pledges report" do
      get :foundation_pledges, {}, as(@staff_user)
      assert_response :success
      assert_template 'foundation_pledges.html.haml'
    end

    should "get the foundation pledges report as csv" do
      get :foundation_pledges, {:format => 'csv'}, as(@staff_user)
      assert_response :success
      assert_equal @response.headers['Content-type'], 'application/ms-excel'
    end
    
    should "get the participant breakdown report" do
      get :participant_breakdown, {}, as(@staff_user)
      assert_response :success
      assert_template 'participant_breakdown.html.haml'
    end

    should "get the participant breakdown report as csv" do
      get :participant_breakdown, {:format => 'csv'}, as(@staff_user)
      assert_response :success
      assert_equal @response.headers['Content-type'], 'application/ms-excel'
    end
  end
end
