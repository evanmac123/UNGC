require "test_helper"

class Admin::DueDiligence::IntegrityReviewControllerTest < ActionController::TestCase
  test "a valid request_integrity_review" do
    # Given we're signed in as an integrity manager
    manager = create(:staff_contact, :integrity_manager)
    sign_in manager

    # And there is an existing review
    review = create(:due_diligence_review, :integrity_review, :with_research)

    mailer_method = mock("mailer_method")
    mailer_method.expects(:deliver_later)
    DueDiligenceReviewMailer.expects(:integrity_decision_rendered).returns(mailer_method)

    # When we engaged the subject of the review
    put :update, valid_params(review.id)

    # And we're redirected to the review show page
    assert_redirected_to for_state_admin_due_diligence_reviews_path(state: [:engagement_review])

    fired_events = event_store.read_events_forward("due_diligence_review_#{review.id}")

    # And 2 events were fired.
    assert_equal 2, fired_events.length, "2 Events were not fired"

    # And our review is still integrity_decision
    review.reload
    assert review.engagement_review?, "review was not engagement review"

    assert_equal 'explanation', review.integrity_explanation

    info_added_events = fired_events.select do |evt|
      evt.is_a? DueDiligence::Events::InfoAdded
    end

    assert_equal 1, info_added_events.count
    info_added = info_added_events.first

    assert_equal manager.id, info_added.data[:requester_id]
    assert_equal review.integrity_explanation, info_added.data[:changes]['integrity_explanation']
  end

  test "a valid rejection" do
    # Given we're signed in as an integrity manager
    manager = create(:staff_contact, :integrity_manager)
    sign_in manager

    # And there is an existing review
    review = create(:due_diligence_review, :integrity_review, :with_research, )

    mailer_method = mock("mailer_method")
    mailer_method.expects(:deliver_later)
    DueDiligenceReviewMailer.expects(:integrity_decision_rendered).returns(mailer_method)

    # When we engaged the subject of the review
    put :update, valid_params(review.id, action: "reject")

    # And we're redirected to the review show page
    assert_redirected_to for_state_admin_due_diligence_reviews_path(state: [:rejected])

    fired_events = event_store.read_events_forward("due_diligence_review_#{review.id}")

    # And 2 events were fired.

    assert_equal 2, fired_events.length, "2 Events were not fired"

    # And our review is still integrity_decision
    review.reload
    assert review.rejected?, "review was not rejected"

    assert_equal 'explanation', review.integrity_explanation

    info_added = event_store.read_events_forward("due_diligence_review_#{review.id}").select do |evt|
      evt.is_a? DueDiligence::Events::InfoAdded
    end.first

    assert_equal manager.id, info_added.data[:requester_id]
    assert_equal review.integrity_explanation, info_added.data[:changes]['integrity_explanation']
  end

  test "a valid with_reservations update" do
    # Given we're signed in as an integrity manager
    manager = create(:staff_contact, :integrity_manager)
    sign_in manager

    # And there is an existing review
    review = create(:due_diligence_review, :integrity_review, :with_research)

    mailer_method = mock("mailer_method")
    mailer_method.expects(:deliver_later)
    DueDiligenceReviewMailer.expects(:integrity_decision_rendered).returns(mailer_method)

    # When we engaged the subject of the review
    put :update, valid_params(review.id, action: "approve_with_reservation")

    # And we're redirected to the review show page
    assert_redirected_to for_state_admin_due_diligence_reviews_path(state: [:engagement_review])

    fired_events = event_store.read_events_forward("due_diligence_review_#{review.id}")

    # And 2 events were fired.
    assert_equal 2, fired_events.length, "2 Events were not fired"

    # And our review is still integrity_decision
    review.reload
    assert review.engagement_review?, "review was not engagement review"

    assert_equal 'explanation', review.integrity_explanation

    info_added = event_store.read_events_forward("due_diligence_review_#{review.id}").select do |evt|
      evt.is_a? DueDiligence::Events::InfoAdded
    end.first

    assert_equal manager.id, info_added.data[:requester_id]
    assert_equal review.integrity_explanation, info_added.data[:changes]['integrity_explanation']
  end

  test "a valid send back to review" do
    # Given we're signed in as an integrity manager
    manager = create(:staff_contact, :integrity_manager)
    sign_in manager

    # And there is an existing review
    review = create(:due_diligence_review, :integrity_review, :with_research)

    # When we engaged the subject of the review
    put :update, valid_params(review.id, action: "send_to_review")

    # And we're redirected to the review show page
    assert_redirected_to for_state_admin_due_diligence_reviews_path(state: [:in_review])

    fired_events = event_store.read_events_forward("due_diligence_review_#{review.id}")

    # And 2 events were fired.
    assert_equal 2, fired_events.length, "2 Events were not fired"

    # And our review is in_review
    review.reload
    assert review.in_review?, "review was not in_review"

    info_added = event_store.read_events_forward("due_diligence_review_#{review.id}").select do |evt|
      evt.is_a? DueDiligence::Events::InfoAdded
    end.first

    assert_equal manager.id, info_added.data[:requester_id]
    assert_equal review.integrity_explanation, info_added.data[:changes]['integrity_explanation']
  end

  test "an invalid update" do
    # Given we're signed in as an integrity manager
    manager = create(:staff_contact, :integrity_manager)
    sign_in manager

    # And there is an existing review
    review = create(:due_diligence_review, :integrity_review, :with_research, )

    # When we engaged the subject of the review
    put :update, valid_params(review.id, explanation: '')

    # Then we're still on the engagement decision page
    assert_response :ok
    assert_template :edit

    # And we're told it failed to render the decision
    assert_equal "Integrity explanation can't be blank", flash[:error]

    # And no events were fired
    assert_empty event_store.read_events_forward("due_diligence_review_#{review.id}"), 'Events were fired'
  end


  private

  def stub_review
    review = build_stubbed(:due_diligence_review)
    DueDiligence::Review.stubs(find: review)
    review
  end

  def valid_params(review_id, explanation: "explanation",
                   action: "approve_without_reservation")
    {
      id: review_id,
      recommendations: {
        integrity_explanation: explanation,
      },
      commit: { action => "approve" }
    }
  end

end
