require 'test_helper'

class DueDiligence::ReviewPolicyTest < ActiveSupport::TestCase

  context 'can create?' do
    context 'UNGC user' do
      should 'be allowed' do
        contact = build_stubbed(:staff_contact)
        assert DueDiligence::ReviewPolicy.can_create?(contact), 'UNGC contact should be able to create'
        assert DueDiligence::ReviewPolicy.can_view?(contact), 'UNGC contact should be able to view'
      end
    end

    context 'non UNGC user' do
      should 'not be allowed' do
        contact = build_stubbed(:contact)
        assert_not DueDiligence::ReviewPolicy.can_create?(contact), 'Non UNGC contact cannot create'
        assert_not DueDiligence::ReviewPolicy.can_view?(contact), 'Non UNGC contact cannot view'
      end
    end
  end

  context 'can_do_due_diligence?' do
    should 'be allowed for a user from the Integrity team' do
      review = build_stubbed(:due_diligence_review, state: :in_review, requester: create(:staff_contact))
      review_policy = DueDiligence::ReviewPolicy.new(review)

      integrity_contact = create(:staff_contact, :integrity_team_member)

      assert review_policy.can_do_due_diligence?(integrity_contact),
             'Integrity team should be able to perform due diligence'

      # can_edit?
      assert review_policy.can_edit?(integrity_contact),
             'Integrity team should be able to edit an in_review'

      review.state = :local_network_review
      assert review_policy.can_edit?(integrity_contact),
             'Integrity team should be able to edit a local_network_review'

      %w[integrity_review engagement_review engaged declined rejected].each do |s|
        review.state = s.to_sym
        assert_not review_policy.can_edit?(integrity_contact),
               "Integrity team should be able to edit when #{review.state}"
      end
    end

    should 'not be allowed for a non-Integrity team user' do
      review = build_stubbed(:due_diligence_review, state: :in_review, requester: create(:staff_contact))
      review_policy = DueDiligence::ReviewPolicy.new(review)

      staff_contact = create(:staff_contact)
      assert_not review_policy.can_do_due_diligence?(staff_contact),
             'Staff user should not be able to perform due diligence'
    end
  end

  context 'can_send_to_integrity?' do
    should 'be allowed for a user from the Integrity team' do
      review = build_stubbed(:due_diligence_review, state: :in_review, requester: create(:staff_contact))
      review_policy = DueDiligence::ReviewPolicy.new(review)

      integrity_contact = create(:staff_contact, :integrity_team_member)
      assert review_policy.can_send_to_integrity?(integrity_contact),
             'Integrity team should be able to send for integrity decision'
    end

    should 'not be allowed for by the requester if the review is :engagment_review' do
      review = build_stubbed(:due_diligence_review, state: :engagement_review, requester: create(:staff_contact))
      review_policy = DueDiligence::ReviewPolicy.new(review)

      assert review_policy.can_send_to_integrity?(review.requester),
                 'Requester user should be able to send to integrity from :engagement_review'
    end

    context 'for invalid states' do
      context 'where user is requester' do
        should 'not be allowed for states :in_review, :engaged, :declined' do
          %w[in_review engaged declined].each do |s|
            review = build_stubbed(:due_diligence_review, requester: create(:staff_contact))
            review_policy = DueDiligence::ReviewPolicy.new(review)

            review.state = s.to_sym
            assert_not review_policy.can_send_to_integrity?(review.requester),
                       "Cannot send to integrity_review from state :#{review.state}"
          end
        end
      end
    end
  end

  context 'can_make_integrity_decision?' do
    should 'be allowed for a user from the Integrity Management team' do
      review = build_stubbed(:due_diligence_review, state: :in_review, requester: create(:staff_contact))
      review_policy = DueDiligence::ReviewPolicy.new(review)

      integrity_contact = create(:staff_contact, :integrity_manager)
      assert review_policy.can_make_integrity_decision?(integrity_contact),
             'Integrity management should be able to make an integrity decision'

      assert review_policy.can_edit?(integrity_contact), 'Integrity contact can edit an integrity decision'
    end

    should 'not be allowed for general integrity team members' do
      review = build_stubbed(:due_diligence_review, :with_research, :integrity_review,
                             requester: create(:staff_contact))
      review_policy = DueDiligence::ReviewPolicy.new(review)

      integrity_contact = create(:staff_contact, :integrity_team_member)
      assert_not review_policy.can_make_integrity_decision?(integrity_contact),
                 'General Integrity Team user should not be able to make an integrity decision'

      assert_not review_policy.can_edit?(integrity_contact), 'Integrity team cannot edit an integrity decision'
    end

    should 'not be allowed for a non-Integrity team user' do
      review = build_stubbed(:due_diligence_review, state: :in_review, requester: create(:staff_contact))
      review_policy = DueDiligence::ReviewPolicy.new(review)

      staff_contact = create(:staff_contact)
      assert_not review_policy.can_make_integrity_decision?(staff_contact),
                 'Staff user should not be able to make an integrity decision'

      assert_not review_policy.can_edit?(staff_contact), 'Staff contact cannot edit an integrity decision'
    end
  end

  context 'can can_make_engagement_decision?' do
    should 'be allowed for a user who is the requester' do
      review = build_stubbed(:due_diligence_review, state: :engagement_review, requester: create(:staff_contact))
      review_policy = DueDiligence::ReviewPolicy.new(review)

      assert review_policy.can_make_engagement_decision?(review.requester),
             'Requester should be able to make an engagement_decision'
      assert review_policy.can_edit?(review.requester), 'Requester can edit an engagement decision'
    end

    should 'be be allowed for a user from Integrity Management' do
      review = build_stubbed(:due_diligence_review, state: :in_review, requester: create(:staff_contact))
      review_policy = DueDiligence::ReviewPolicy.new(review)

      integrity_contact = create(:staff_contact, :integrity_manager)
      assert review_policy.can_make_engagement_decision?(integrity_contact),
                 'Integrity manager should be able to make an engagement_decision'
      assert review_policy.can_edit?(integrity_contact), 'Integrity Manager can edit an engagement decision'
    end

    should 'be not be allowed for a user from the Integrity team' do
      review = build_stubbed(:due_diligence_review, :integrity_review, requester: create(:staff_contact))
      review_policy = DueDiligence::ReviewPolicy.new(review)

      integrity_contact = create(:staff_contact, :integrity_team_member)
      assert_not review_policy.can_make_engagement_decision?(integrity_contact),
                 'Integrity team should not be able to make an engagement_decision'
      assert_not review_policy.can_edit?(integrity_contact),
                 'Integrity team should not be able to edit an engagement_decision'
    end
  end

  context 'can destroy?' do
    should 'be allowed for a user who is the requester' do
      review = build_stubbed(:due_diligence_review, state: :in_review, requester: create(:staff_contact))
      review_policy = DueDiligence::ReviewPolicy.new(review)
      assert review_policy.can_destroy?(review.requester), 'Requester should be able to delete'
    end

    should 'be allowed for a user from the Integrity team' do
      review = build_stubbed(:due_diligence_review, state: :in_review, requester: create(:staff_contact))
      review_policy = DueDiligence::ReviewPolicy.new(review)

      integrity_contact = create(:staff_contact, :integrity_team_member)
      assert review_policy.can_destroy?(integrity_contact), 'Integrity team should be able to delete'
    end

    should 'not be allowed for a user who is not the requester' do
      review = build_stubbed(:due_diligence_review, state: :in_review, requester: create(:staff_contact))
      review_policy = DueDiligence::ReviewPolicy.new(review)
      staff_contact = create(:staff_contact)

      assert_not review_policy.can_destroy?(staff_contact),
                 'Random staff should not be able to delete'
    end

    should 'not be allowed for states integrity_review, engagement_review, approved, rejected, declined' do
      review = build_stubbed(:due_diligence_review, :with_research, state: :integrity_review,
                             requester: create(:staff_contact))
      review_policy = DueDiligence::ReviewPolicy.new(review)

      %w[integrity_review engagement_review engaged declined rejected].each do |s|
        review.state = s.to_sym
        assert_not review_policy.can_destroy?(review.requester),
                   "Cannot delete in state :#{review.state}"
      end

      assert_not review_policy.can_destroy?(review.requester),
                 'Cannot delete in state integrity_review'

      review.state = :local_network_review
      assert_not review_policy.can_destroy?(review.requester),
                 'Cannot delete in state local_network_review'

      review.state = :engagement_review
      assert_not review_policy.can_destroy?(review.requester),
                 'Cannot delete in state engagement_review'

      review.state = :approved
      assert_not review_policy.can_destroy?(review.requester),
                 'Cannot delete in state approved'

      review.state = :declined
      assert_not review_policy.can_destroy?(review.requester),
                 'Cannot delete in state declined'

      review.state = :rejected
      assert_not review_policy.can_destroy?(review.requester),
                 'Cannot delete in state rejected'
    end
  end
end
