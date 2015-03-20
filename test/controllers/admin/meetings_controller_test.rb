require 'test_helper'

class Admin::MeetingsControllerTest < ActionController::TestCase
  include LocalNetworkSubmodelControllerHelper

  context "generated" do

    setup do
      sign_in_as_local_network
      @meeting = create_meeting(local_network: @local_network)
      @local_network.meetings << @meeting
    end

    should "post => #create" do
      assert_difference '@local_network.meetings.count', +1 do
        post :create, local_network_id: @local_network, meeting: params
      end
    end

    should "get => #new" do
      get :new, local_network_id: @local_network
      assert_response :success
    end

    should "get => #edit" do
      get :edit, local_network_id: @local_network, id: @meeting
      assert_response :success
    end

    should "put => #update" do
      put :update, local_network_id: @local_network, id: @meeting, meeting: params
    end

    should "delete => #destroy" do
      assert_difference '@local_network.meetings.count', -1 do
        delete :destroy, local_network_id: @local_network, id: @meeting
      end
    end

  end

  def params
    valid_meeting_attributes
      .with_indifferent_access
      .slice(:date, :file)
  end
end
