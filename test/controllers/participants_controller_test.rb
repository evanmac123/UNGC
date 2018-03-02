require 'test_helper'

class ParticipantsControllerTest < ActionController::TestCase

  setup do
    create(:container, path: '/what-is-gc/participants')
  end

  test "signatory level profile" do
    get :show, id: create(:business,
      level_of_participation: :signatory_level)

    assert_response :success
    assert_template "_signatory_tier"
  end

  test "participant level profile" do
    get :show, id: create(:business,
      level_of_participation: :participant_level)

    assert_response :success
    assert_template "_participant_tier"
  end

  test "signatory level profile is the default" do
    get :show, id: create(:business,
      level_of_participation: nil)

    assert_response :success
    assert_template "_signatory_tier"
  end

  test "not show non-participants" do
    get :show, id: create(:business, participant: false)

    assert_response :not_found
  end

  test "shows employees for business" do
    business = create(:business, employees: 123)
    get :show, id: business

    assert_response :success
    assert_select "dd[role='employees']", "123"
  end

  test "does NOT show employees for non-business" do
    non_business = create(:non_business, employees: 123)
    get :show, id: non_business

    assert_response :success
    assert_select "dd[role='employees']", false
  end

end
