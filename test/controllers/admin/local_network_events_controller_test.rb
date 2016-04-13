require 'test_helper'

class Admin::LocalNetworkEventsControllerTest < ActionController::TestCase
  include LocalNetworkSubmodelControllerHelper

  context "generated" do

    setup do
      sign_in_as_local_network
      @event = create(:local_network_event,
        local_network_id: @local_network.id,
        uploaded_attachments: [attachment: create_file_upload]
      )
      @local_network.events << @event
    end

    should "post => #create" do
      total = @local_network.events.count
      post :create, local_network_id: @local_network, local_network_event: params
      assert_response :success
      assert (total + 1), @local_network.events.reload.count
    end

    should "get => #new" do
      get :new, local_network_id: @local_network
      assert_response :success
    end

    should "get => #edit" do
      get :edit, local_network_id: @local_network, id: @event
      assert_response :success
    end

    should "get => #show" do
      get :show, local_network_id: @local_network, id: @event
    end

    should "put => #update" do
      put :update, local_network_id: @local_network, id: @event,
        local_network_event: params
    end

    should "delete => #destroy" do
      assert_difference '@local_network.events.count', -1 do
        delete :destroy, local_network_id: @local_network, id: @event
      end
    end

  end

  def params
    attributes_for(:local_network_event)
      .merge(valid_file_upload_attributes)
      .slice(
        :title,
        :description,
        :event_type,
        :date,
        :num_participants,
        :gc_participant_percentage,
        :uploaded_attachments
      )
  end
end
