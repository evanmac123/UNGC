require 'test_helper'

class GraceLettersControllerTest < ActionController::TestCase

  test "show" do
    create_approved_organization_and_user
    create_cop_with_options(type: 'grace')
    get :show, :organization_id => @organization.id,
               :id              => @cop.id
    assert_response :success
    assert assigns(:grace_letter)
  end

end
