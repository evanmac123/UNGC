require 'test_helper'


class Admin::CopFilesControllerTest < ActionController::TestCase

  context "generated" do

    setup do
      create(:language, name: 'English')
      create_organization_and_user
      @organization.approve!
      @cop = create(:communication_on_progress, organization: @organization)
      @file = create(:cop_file, cop_id: @cop.id, attachment: create_file_upload)
      sign_in @organization_user
    end

    should "get => #index" do
      get :index,
        organization_id: @organization.id,
        communication_on_progress_id: @cop.id
      assert_response :success
    end

    should "post => #create" do
      assert_difference '@cop.cop_files.count', +1 do
        post :create,
          organization_id: @organization.id,
          communication_on_progress_id: @cop.id,
          uploaded_attachments: [ attachment: create_file_upload ]
      end
      assert_response :redirect
    end

    should "get => #new" do
      get :new,
        organization_id: @organization.id,
        communication_on_progress_id: @cop.id
      assert_response :success
    end

    should "delete => #destroy" do
      assert_difference '@cop.cop_files.count', -1 do
        delete :destroy,
          organization_id: @organization.id,
          communication_on_progress_id: @cop.id,
          id: @file.id
      end
      assert_response :redirect
    end

  end
end
