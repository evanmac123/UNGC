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
end
