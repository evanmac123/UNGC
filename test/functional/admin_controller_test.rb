require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  
  context "given a UNGC staff member" do
    setup do
      create_organization_and_user
      add_organization_data(@organization, @organization_user)
      login_as create_staff_user
    end

    should "get the dashboard page" do
      # now get the dashboard
      get :dashboard
      assert_response :success
      assert_template 'admin/dashboard_ungc.html.haml'
    end
  end
  
  context "given a approved organization member" do
    setup do
      user = create_organization_and_user
      @organization.update_attribute :state, 'approved'
      add_organization_data(@organization, user)
      login_as user
    end

    should "get the dashboard page" do
      get :dashboard
      assert_response :success
      assert_template 'admin/dashboard_organization.html.haml'
    end
  end
  
  context "given a pending organization member" do
    setup do
      user = create_organization_and_user
      create_comment(:commentable_id   => @organization.id,
                     :commentable_type => 'Organization',
                     :contact_id       => @organization_user.id)
      login_as user
    end

    should "get the dashboard page" do
      get :dashboard
      assert_response :success
      assert_template 'admin/dashboard_organization.html.haml'
    end
  end
  
  private
    def add_organization_data(organization, user)
      # add some content to the organization
      create_logo_publication
      create_communication_on_progress(:organization_id => organization.id)
      create_case_story(:organization_id => organization.id)
      create_logo_request(:organization_id => organization.id,
                          :contact_id      => user.id)
    end
end
