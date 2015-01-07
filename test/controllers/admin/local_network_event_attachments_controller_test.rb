require 'test_helper'


class Admin::LocalNetworkEventAttachmentsControllerTest < ActionController::TestCase
  include LocalNetworkSubmodelControllerHelper

  context "generated" do

    setup do
      sign_in_as_local_network
      @event = create_local_network_event(
        local_network_id: @local_network.id,
        uploaded_attachments: [attachment: create_file_upload]
      )
      @local_network.events << @event
      @attachment = @event.attachments.last
    end

    should "#create" do
      assert_difference '@event.attachments.count', +1 do
        post :create,
          local_network_id: @local_network,
          local_network_event_id: @event,
          uploaded_attachments: [ attachment: create_file_upload ]
      end
      assert_response :redirect
    end

    should "#new" do
      get :new,
        local_network_id: @local_network,
        local_network_event_id: @event
      assert_response :success
    end

    should "#destroy" do
      assert_difference '@event.attachments.count', -1 do
        delete :destroy,
          local_network_id: @local_network,
          local_network_event_id: @event,
          id: @attachment
      end
      assert_response :redirect
    end

  end
end
