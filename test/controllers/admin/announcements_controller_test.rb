require 'test_helper'

class Admin::AnnouncementsControllerTest < ActionController::TestCase
  include LocalNetworkSubmodelControllerHelper

  context "generated" do

    setup do
      sign_in_as_local_network
      @announcement = create(:announcement, local_network: @local_network)
      @local_network.announcements << @announcement
    end

    should "post => #create" do
      assert_difference '@local_network.announcements.count', +1 do
        post :create,
          local_network_id: @local_network,
          announcement: params
      end
      assert_response :redirect
    end

    should "post => #create reject with validations" do
      invalid_params = {
        title: nil,
        description: "d"*300
      }
      post :create,
        local_network_id: @local_network,
        announcement: invalid_params
      assert_template 'new'
      assert_select '.flash.error ul li', 2
    end

    should "get => #new" do
      get :new, local_network_id: @local_network
      assert_response :success
    end

    should "get => #edit" do
      get :edit, local_network_id: @local_network, id: @announcement
      assert_response :success
    end

    should "put => #update" do
      put :update,
        local_network_id: @local_network,
        id: @announcement,
        announcement: params
      assert_response :redirect
    end

    should "delete => #destroy" do
      assert_difference '@local_network.announcements.count', -1 do
        delete :destroy, local_network_id: @local_network, id: @announcement
      end
      assert_response :redirect
    end

  end

  def params
    attributes_for(:announcement)
      .with_indifferent_access
      .slice(:title, :description, :date)
  end
end
