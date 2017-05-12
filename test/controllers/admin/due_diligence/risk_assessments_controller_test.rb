require "test_helper"

class Admin::DueDiligence::RiskAssessmentsControllerTest < ActionController::TestCase

  test "a valid submission to integrity_review" do
    # Given we're signed in as staff
    contact = create(:staff_contact, :integrity_team_member)
    sign_in contact

    # And there is an existing review
    review = create(:due_diligence_review, :with_research, state: :in_review, requester: contact)

    # When we engaged the subject of the review
    patch :update, id: review,
          commit: { request_integrity_review: "" },
          review: {
              analysis_comments: "I did lots of research."
          }

    # And we're redirected to the review show page
    assert_redirected_to for_state_admin_due_diligence_reviews_path(state: [:integrity_review])


    fired_events = event_store.read_events_forward("due_diligence_review_#{review.id}")

    # And our review is now approved
    review.reload
    assert review.integrity_review?, "review was not in integrity_review"

    # With the decision text and it's maker
    assert_equal "I did lots of research.", review.analysis_comments

    info_added_events = fired_events.select do |evt|
      evt.is_a? DueDiligence::Events::InfoAdded
    end

    assert_equal 1, info_added_events.count
    info_added = info_added_events.first

    assert_equal contact.id, info_added.data[:requester_id]
    assert_equal review.analysis_comments, info_added.data[:changes]['analysis_comments']
  end

  test "a valid submission to local_network_input" do
    # Given we're signed in as staff
    contact = create(:staff_contact, :integrity_team_member)
    sign_in contact

    # And there is an existing review
    review = create(:due_diligence_review, :with_research, state: :in_review)

    # When we engaged the subject of the review
    patch :update, id: review,
          commit: { request_local_network_input: "" },
          review: {
              analysis_comments: "I did lots of research."
          }

    # And we're redirected to the review show page
    assert_redirected_to for_state_admin_due_diligence_reviews_path(state: [:local_network_review])

    fired_events = event_store.read_events_forward("due_diligence_review_#{review.id}")

    # And 2 events were fired.
    assert_equal 2, fired_events.length, "2 events were not fired"

    # And our review is now approved
    review.reload

    assert review.requires_local_network_input?, "requires_local_network_input not set"
    assert review.local_network_review?, "review was not in local network review"

    # With the decision text and it's maker
    assert_equal "I did lots of research.", review.analysis_comments

    info_added = fired_events.select do |evt|
      evt.is_a? DueDiligence::Events::InfoAdded
    end.first

    assert_equal contact.id, info_added.data[:requester_id]
    assert_equal review.analysis_comments, info_added.data[:changes]['analysis_comments']
  end

  test "an invalid update" do
    # Given we're signed in as staff
    sign_in create(:staff_contact, :integrity_team_member)

    # and there is an existing review
    review = create(:due_diligence_review, :with_research, state: :in_review)

    # When we fail to give it the proper input
    patch :update, id: review,
          commit: { request_integrity_review: "" },
          review: {
              analysis_comments: ""
          }

    # Then we're still on the engagement decision page
    assert_response :ok
    assert_template :edit

    # And we're told it failed to render the decision
    assert_equal "Analysis comments can't be blank", flash[:error]

    # And no events were fired
    assert_empty event_store.read_events_forward("due_diligence_review_#{review.id}")
  end

  private

  def event_store
    RailsEventStore::Client.new
  end

end
