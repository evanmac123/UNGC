require "test_helper"

class IglooSignInTrackerTest < ActiveSupport::TestCase

  test "should create a new IglooUser when one doesn't exist" do
    contact = create(:contact)

    tracker = IglooSignInTracker.new
    assert_difference -> { IglooUser.count }, +1 do
      tracker.perform(contact.id)
    end
  end

  test "should update an existing IglooUser" do
    contact = create(:contact)

    first_login = 10.days.ago
    igloo_user = create(:igloo_user, contact: contact,
      created_at: first_login, updated_at: first_login)

    tracker = IglooSignInTracker.new
    tracker.perform(contact.id)
    igloo_user.reload

    assert igloo_user.updated_at > first_login
  end

end

