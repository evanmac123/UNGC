require "test_helper"

class Admin::DueDiligence::ReviewsControllerTest < ActionController::TestCase

  test "a valid submission to in_review" do
    # Given we're signed in as staff
    contact = create(:staff_contact)
    create(:staff_contact, :integrity_manager)

    sign_in contact

    organization = create(:organization)

    # When we engaged the subject of the review
    post :create,
          commit: { request_integrity_review: "" },
          review: {
              organization_name: organization.name,
              level_of_engagement: DueDiligence::Review.levels_of_engagement[:sponsor],
              additional_information: 'I hope we can engage them.',
          }

    # And we're redirected to the review show page
    assert_redirected_to for_state_admin_due_diligence_reviews_path(state: [:in_review]), flash[:error]

    review = DueDiligence::Review.order(created_at: :desc, id: :desc).first

    fired_events = event_store.read_events_forward("due_diligence_review_#{review.id}")

    # And our review is now approved
    review.reload
    assert review.in_review?, "review was not in_review?"

    info_added_events = fired_events.select do |evt|
      evt.is_a? DueDiligence::Events::InfoAdded
    end

    assert_equal 1, info_added_events.count
    info_added = info_added_events.first

    assert_equal contact.id, info_added.data[:requester_id]
    assert_equal review.level_of_engagement.to_s, info_added.data[:changes]['level_of_engagement']
    assert_equal review.additional_information, info_added.data[:changes]['additional_information']
  end

  private

  def event_store
    RailsEventStore::Client.new
  end

end
