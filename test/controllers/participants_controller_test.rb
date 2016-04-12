require 'test_helper'

class ParticipantsControllerTest < ActionController::TestCase

  setup do
    create(:container, path: '/what-is-gc/participants')
  end

  test 'should get show' do
    create_organization_and_user
    @organization.update(participant: true)

    get :show, id: @organization

    assert_response :success
    assert_not_nil assigns(:page)
  end

  should 'not show non-participants' do
    create_organization_and_user

    get :show, id: @organization

    assert_response :not_found
  end

end
