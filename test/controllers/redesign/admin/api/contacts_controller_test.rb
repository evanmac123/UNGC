require 'test_helper'

class Redesign::Admin::Api::ContactsControllerTest < ActionController::TestCase

  setup do
    create_staff_user
    sign_in @staff_user
  end

  test "gets current users" do
    get :current
    assert_response :success
    assert_equal JSON.parse(response.body), {
      "contact" => {
        "id" => @staff_user.id,
        "name" => @staff_user.name,
        "type" => 'contact',
        "is_website_editor" => false
      }
    }

  end

end

