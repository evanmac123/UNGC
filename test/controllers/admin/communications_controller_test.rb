require 'test_helper'

class Admin::CommunicationsControllerTest < ActionController::TestCase
  include LocalNetworkSubmodelControllerHelper

  context "generated" do

    setup do
      sign_in_as_local_network
      @communication = create(:communication, local_network: @local_network)
      @local_network.communications << @communication
    end

    should "post => #create" do
      assert_difference '@local_network.communications.count', +1 do
        post :create,
             local_network_id: @local_network,
             communication: params
      end
      assert_response :redirect
    end

    should "get => #new" do
      get :new, local_network_id: @local_network
      assert_response :success
    end

    should "get => #edit" do
      get :edit, local_network_id: @local_network, id: @communication
      assert_response :success
    end

    should "put => #update" do
      put :update, local_network_id: @local_network, id: @communication, communication: params
      assert_response :redirect
    end

    should "delete => #destroy" do
      assert_difference '@local_network.communications.count', -1 do
        delete :destroy, local_network_id: @local_network, id: @communication
      end
      assert_response :redirect
    end

  end

  def params
    attributes_for(:communication).
      merge(valid_file_upload_attributes).
      slice(:title, :date, :file)
  end
end
