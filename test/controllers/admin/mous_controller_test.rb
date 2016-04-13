require 'test_helper'

class Admin::MousControllerTest < ActionController::TestCase
  include LocalNetworkSubmodelControllerHelper

  context "generated" do

    setup do
      sign_in_as_local_network
      @mou = create(:mou, local_network: @local_network)
      @local_network.mous << @mou
    end

    should "post => #create" do
      assert_difference '@local_network.mous.count', +1 do
        post :create, local_network_id: @local_network,
          mou: params
      end
      assert_response :redirect
    end

    should "get => #new" do
      get :new, local_network_id: @local_network
      assert_response :success
    end

    should "get => #edit" do
      get :edit, local_network_id: @local_network, id: @mou
      assert_response :success
    end

    should "put => #update" do
      put :update, local_network_id: @local_network, id: @mou,
        mou: params
      assert_response :redirect
    end

    should "delete => #destroy" do
      assert_difference '@local_network.mous.count', -1 do
        delete :destroy, local_network_id: @local_network, id: @mou
      end
      assert_response :redirect
    end

  end

  def params
    valid_file_upload_attributes
  end
end
