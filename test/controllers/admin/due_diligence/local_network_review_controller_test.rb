require "test_helper"

class Admin::DueDiligence::LocalNetworkReviewControllerTest < ActionController::TestCase

  test "a valid submission to integrity_review" do
    # Given we're signed in as an integrity team member
    integrity_team = create(:staff_contact, :integrity_team_member)
    create(:staff_contact, :integrity_manager)
    sign_in integrity_team

    # And there is an existing review
    review = create(:due_diligence_review, :with_research,
                    state: :local_network_review,
                    requires_local_network_input: true,
    )

    # When we engaged the subject of the review
    patch :update, id: review,
          commit: { request_integrity_review: "" },
          local_network_input: {
              local_network_input: "We approved at the local level."
          }


    # And we're redirected to the review show page
    assert_redirected_to for_state_admin_due_diligence_reviews_path(state: [:integrity_review])

    fired_events = event_store.read_events_forward("due_diligence_review_#{review.id}")

    # And 2 events were fired.
    assert_equal 2, fired_events.length, "2 events were not fired"

    # And our review is now approved
    review.reload
    assert review.integrity_review?, "review was not in integrity_review"

    # With the decision text and it's maker
    assert_equal "We approved at the local level.", review.local_network_input

    info_added = fired_events.select do |evt|
      evt.is_a? DueDiligence::Events::InfoAdded
    end.first

    assert_equal integrity_team.id, info_added.data[:requester_id]
    assert_equal review.local_network_input, info_added.data[:changes]['local_network_input']
  end

  test "a valid submission to in_review" do
    # Given we're signed in as an integrity team member
    integrity_team = create(:staff_contact, :integrity_team_member)
    sign_in integrity_team

    # And there is an existing review
    review = create(:due_diligence_review, :with_research,
                    state: :local_network_review,
                    requires_local_network_input: true,
    )

    # When we engaged the subject of the review
    patch :update, id: review,
          commit: { send_to_review: "" },
          local_network_input: {
              local_network_input: "We approved at the local level."
          }

    # And we're redirected to the review show page
    assert_redirected_to for_state_admin_due_diligence_reviews_path(state: [:in_review])

    fired_events = event_store.read_events_forward("due_diligence_review_#{review.id}")

    # And 2 events were fired.
    assert_equal 2, fired_events.length, "2 events were not fired"

    # And our review is now approved
    review.reload

    # With the decision text and it's maker
    assert_equal "We approved at the local level.", review.local_network_input

    info_added = fired_events.select do |evt|
      evt.is_a? DueDiligence::Events::InfoAdded
    end.first

    assert_equal integrity_team.id, info_added.data[:requester_id]
    assert_equal review.local_network_input, info_added.data[:changes]['local_network_input']
  end

  test "an invalid update" do
    # Given we're signed in as an integrity team member
    sign_in create(:staff_contact, :integrity_team_member)

    # and there is an existing review
    review = create(:due_diligence_review, :with_research,
                    state: :local_network_review,
                    requires_local_network_input: true,
    )

    # When we fail to give it the proper input
    patch :update, id: review,
          commit: { request_integrity_review: "" },
          local_network_input: {
              local_network_input: ''
          }

    # Then we're still on the engagement decision page
    assert_response :ok
    assert_template :edit

    # And we're told it failed to render the decision
    assert_equal "Local network input can't be blank", flash[:error]

    # And no events were fired
    assert_empty event_store.read_events_forward("due_diligence_review_#{review.id}")
  end

end
