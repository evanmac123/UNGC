require 'test_helper'

class ResourcesControllerTest < ActionController::TestCase
  context "visiting a single resource" do
    setup do
      @resource = create_resource(year: Date.today)
      @resource.approve!
    end

    should "increment views count" do
      assert_equal @resource.views, 0
      get :show, :id => @resource.id
      assert_response :success
      @resource.reload
      assert_equal @resource.views, 1
    end
  end

  context "clicking a resource link" do
    setup do
      @resource = create_resource(year: Date.today)
      @resource.approve!
      @resource_link = create_resource_link(resource: @resource)
    end

    should "increment views count" do
      assert_equal @resource_link.views, 0
      post :link_views, :resource_link_id => @resource_link.id, format: :js
      assert_response :success
      @resource_link.reload
      assert_equal @resource_link.views, 1
    end
  end
end
