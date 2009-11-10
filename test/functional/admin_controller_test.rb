require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  
  context "given a UNGC staff member" do
    setup do
      login_as create_staff_user
    end

    should "get the dashboard page" do
      get :dashboard
      assert_response :success
      assert_template 'admin/dashboard_ungc.html.haml'
    end
  end
  
  context "given a organization member" do
    setup do
      login_as create_organization_and_user
    end

    should "get the dashboard page" do
      get :dashboard
      assert_response :success
      assert_template 'admin/dashboard_organization.html.haml'
    end
  end
end
