require 'test_helper'


class Admin::UploadedFilesControllerTest < ActionController::TestCase

  context "generated" do

    setup do
      create_staff_user
      sign_in @staff_user
      @file = UploadedFile.create! attachment: create_file_upload, attachable_type: 'fake'
    end

    should "get => #show" do
      get :show, id: @file.id, filename: @file.attachment_file_name
    end

  end
end
