require 'test_helper'

class Admin::ResourcesControllerTest < ActionController::TestCase

  context "When not signed in." do
    should "not have access" do
      get :index
      assert_response 302
    end
  end

  context "When signed in, but not from the UNGC" do
    should "not have access" do
      sign_in create_organization_and_user
      get :index
      assert_response 302
    end
  end

  context "When signed in as a member of the UNGC" do

    setup do
      sign_in create_staff_user
    end

    should "get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:resources)
    end

    should "get show" do
      resource = create_resource
      get :show, id:resource
      assert_response :success
      assert_not_nil assigns(:resource)
    end

    should "get new" do
      get :new
      assert_response :success
      assert_not_nil assigns(:resource)
    end

    should "get edit" do
      resource = create_resource
      get :edit, id:resource
      assert_response :success
      assert_not_nil assigns(:resource)
    end

    should "delete" do
      resource = create_resource
      delete :destroy, id:resource
      assert_redirected_to action: :index
      assert_equal 0, Resource.count
    end

    context "with valid attributes" do

      should "create and redirect to the index" do
        post :create, resource:valid_resource_attributes
        assert_redirected_to action: :index
        assert_equal 1, Resource.count
      end

      should "update and redirect to show" do
        resource = create_resource
        params = valid_resource_attributes

        put :update, id:resource, resource:params

        assert_redirected_to action: :show
        resource.reload
        assert_equal params['title'], resource.title
      end
    end

    context "with invalid attributes" do

      should "render new action" do
        post :create, resource:{}
        assert_template :new
        assert_equal 0, Resource.count
      end

      should "render edit action" do
        resource = create_resource
        put :update, id:resource, resource:{title: nil}
        assert_template :edit
      end
    end

  end

end
