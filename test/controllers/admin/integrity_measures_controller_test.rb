require 'test_helper'

class Admin::IntegrityMeasuresControllerTest < ActionController::TestCase
  include LocalNetworkSubmodelControllerHelper

  context "generated" do

    setup do
      sign_in_as_local_network
      @integrity_measure = create_integrity_measure(local_network: @local_network)
      @local_network.integrity_measures << @integrity_measure
    end

    should "post => #create" do
      assert_difference '@local_network.integrity_measures.count', +1 do
        post :create, local_network_id: @local_network,
          integrity_measure: params
      end
      assert_response :redirect
    end

    should "get => #new" do
      get :new, local_network_id: @local_network
      assert_response :success
    end

    should "get => #edit" do
      get :edit, local_network_id: @local_network, id: @integrity_measure
      assert_response :success
    end

    should "put => #update" do
      put :update, local_network_id: @local_network, id: @integrity_measure,
        integrity_measure: params
      assert_response :redirect
    end

    should "delete => #destroy" do
      assert_difference '@local_network.integrity_measures.count', -1 do
        delete :destroy, local_network_id: @local_network, id: @integrity_measure
      end
      assert_response :redirect
    end

  end

  def params
    valid_integrity_measure_attributes
      .with_indifferent_access
      .slice(:title, :description, :date, :file)
  end
end
