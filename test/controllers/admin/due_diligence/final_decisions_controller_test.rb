require "test_helper"

class Admin::DueDiligence::FinalDecisionsControllerTest < ActionController::TestCase

  test "a valid update" do
    # Given we're signed in as staff
    contact = create(:staff_contact)
    sign_in contact

    # And there is an existing review
    review = create(:due_diligence_review, :engagement_review, requester: contact)

    # When we engaged the subject of the review
    patch :update, id: review,
          commit: { engage: "" },
          final_decision: {
              engagement_rationale: "This is my final decision.",
              approving_chief: "Alice Walker",
          }

    # And we're redirected to the review show page
    assert_redirected_to for_state_admin_due_diligence_reviews_path(state: [:engaged])

    fired_events = event_store.read_events_forward("due_diligence_review_#{review.id}")

    # And our review is now approved
    review.reload
    assert review.engaged?, "review was not engaged"

    # With the decision text and it's maker
    assert_equal "This is my final decision.", review.engagement_rationale
    assert_equal "Alice Walker", review.approving_chief

    info_added = fired_events.select do |evt|
      evt.is_a? DueDiligence::Events::InfoAdded
    end.first

    assert_equal contact.id, info_added.data[:requester_id]
    assert_equal review.engagement_rationale, info_added.data[:changes]['engagement_rationale']
    assert_equal review.approving_chief, info_added.data[:changes]['approving_chief']
  end

  test "an invalid update" do
    # Given we're signed in as staff
    contact = create(:staff_contact)
    sign_in(contact)

    # and there is an existing review
    review = create(:due_diligence_review, :engagement_review, requester: contact)

    # When we fail to give it the proper input
    patch :update, id: review,
          commit: { engage: "" },
          final_decision: {
              engagement_rationale: "",
              approving_chief: "Alice Walker",
          }

    # Then we're still on the engagement decision page
    assert_response :ok
    assert_template :edit

    # And we're told it failed to render the decision
    assert_equal "Engagement rationale can't be blank", flash[:error]

    # And no events were fired
    assert_empty event_store.read_events_forward("due_diligence_review_#{review.id}")
  end

  private

  def event_store
    RailsEventStore::Client.new
  end

end
