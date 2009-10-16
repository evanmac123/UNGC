require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  context "given a staff user" do
    setup do
    end
    
    should "get the index page" do
      get :index
      assert_response :success
    end
    
    should "get the approved logo request report" do
      get :approved_logo_requests
      assert_response :success
      assert_template 'approved_logo_requests.html.haml'
    end

    should "get the approved logo request report as csv" do
      get :approved_logo_requests, :format => 'csv'
      assert_response :success
      assert_equal @response.headers['Content-type'], 'application/ms-excel'
    end

    should "get the listed companies report" do
      get :listed_companies
      assert_response :success
      assert_template 'listed_companies.html.haml'
    end

    should "get the listed companies report as csv" do
      get :listed_companies, :format => 'csv'
      assert_response :success
      assert_equal @response.headers['Content-type'], 'application/ms-excel'
    end

    should "get the companies without contacts report" do
      get :companies_without_contacts
      assert_response :success
      assert_template 'companies_without_contacts.html.haml'
    end

    should "get the companies without contacts report as csv" do
      get :companies_without_contacts, :format => 'csv'
      assert_response :success
      assert_equal @response.headers['Content-type'], 'application/ms-excel'
    end
  end
end
