require 'test_helper'

class Admin::AwardsControllerTest < ActionController::TestCase
  include LocalNetworkSubmodelControllerHelper

  context "generated" do

    setup do
      sign_in_as_local_network
      @award = create_award(local_network: @local_network)
      @local_network.awards << @award
    end

    should "post => #create" do
      assert_difference '@local_network.awards.count', +1 do
        post :create,
          local_network_id: @local_network,
          award: params
      end
      assert_response :redirect
    end

    should "get => #new" do
      get :new, local_network_id: @local_network
      assert_response :success
    end

    should "get => #edit" do
      get :edit, local_network_id: @local_network, id: @award
      assert_response :success
    end

    should "put => #update" do
      put :update,
        local_network_id: @local_network,
        id: @award,
        award: params
      assert_response :redirect
    end

    should "delete => #destroy" do
      assert_difference '@local_network.awards.count', -1 do
        delete :destroy, local_network_id: @local_network, id: @award
      end
      assert_response :redirect
    end

  end

  def params
    valid_award_attributes
      .merge(valid_file_upload_attributes)
      .with_indifferent_access
      .slice(:title, :description, :date, :file)
  end
end
