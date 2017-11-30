require 'test_helper'
class DueDiligenceReviewMailerTest < ActionMailer::TestCase

  test 'new_review_for_research' do
    integrity_team_member = create(:staff_contact, :integrity_team_member)
    integrity_manager = create(:staff_contact, :integrity_manager)

    review = create(:due_diligence_review, state: :in_review)

    mail = DueDiligenceReviewMailer.new_review_for_research(review.id, review.requester)

    assert_includes mail.subject, "New Due Diligence Request"
    assert_includes mail.subject, review.organization.name
    assert_includes mail.to, integrity_team_member.email, 'Email not send to an Integrity Team Member'
    assert_includes mail.to, integrity_manager.email, 'Email not send to an Integrity Manager'
    assert_equal [UNGC::Application::EMAIL_SENDER], mail.from
  end

  test 'new_review_for_integrity_decision' do
    integrity_manager = create(:staff_contact, :integrity_manager)

    review = create(:due_diligence_review, :with_research, :integrity_review)

    mail = DueDiligenceReviewMailer.new_review_for_integrity_decision(review.id, integrity_manager)

    assert_includes mail.subject, "Integrity Decision Requested"
    assert_includes mail.subject, review.organization.name
    assert_includes mail.to, integrity_manager.email, 'Email not send to an  Integrity Manager'
    assert_equal [UNGC::Application::EMAIL_SENDER], mail.from
  end

  test 'integrity_decision_rendered' do
    integrity_manager = create(:staff_contact, :integrity_manager)
    review = create(:due_diligence_review, :with_research, :integrity_review, state: :engagement_review)

    mail = DueDiligenceReviewMailer.integrity_decision_rendered(review.id, integrity_manager)

    assert_includes mail.subject, "Integrity Decision Rendered"
    assert_includes mail.subject, review.organization.name
    assert_equal [review.requester.email], mail.to
    assert_equal [UNGC::Application::EMAIL_SENDER], mail.from
  end

  test 'integrity_decision_rendered -- rejected' do
    integrity_manager = create(:staff_contact, :integrity_manager)
    review = create(:due_diligence_review, :with_research, :integrity_review, state: :rejected)

    mail = DueDiligenceReviewMailer.integrity_decision_rendered(review.id, integrity_manager)

    assert_includes mail.subject, "Integrity Decision Rendered"
    assert_includes mail.subject, review.organization.name
    assert_equal [review.requester.email], mail.to
    assert_equal [UNGC::Application::EMAIL_SENDER], mail.from
  end

  test 'engagement_decision_rendered' do
    integrity_team_member = create(:staff_contact, :integrity_team_member)
    integrity_manager = create(:staff_contact, :integrity_manager)

    review = create(:due_diligence_review, :engagement_review, state: :engaged)

    mail = DueDiligenceReviewMailer.engagement_decision_rendered(review.id, review.requester)

    assert_includes mail.subject, "Engagement Decision Rendered"
    assert_includes mail.subject, review.organization.name
    assert_includes mail.to, integrity_team_member.email, 'Email not send to an Integrity Team Member'
    assert_includes mail.to, integrity_manager.email, 'Email not send to an Integrity Manager'
    assert_equal [UNGC::Application::EMAIL_SENDER], mail.from
  end

  test "comment_notifier" do
    review = create(:due_diligence_review)
    comment = create(:comment, commentable: review)
    mail = DueDiligenceReviewMailer.comment_notifier(comment.id)
    assert_equal "#{comment.contact.name} commented on #{review.organization_name}'s Due Diligence Review", mail.subject
    assert_equal ["integrityteam@unglobalcompact.org"], mail.to
    assert_equal [UNGC::Application::EMAIL_SENDER], mail.from
  end

  test "comment_notifier to participant manager" do
    review = create(:due_diligence_review)
    comment = create(:comment, commentable: review)
    mail = DueDiligenceReviewMailer.comment_notifier(comment.id, true)
    assert_equal "#{comment.contact.name} commented on #{review.organization_name}'s Due Diligence Review", mail.subject
    assert_equal [review.organization.participant_manager.email], mail.to
    assert_equal [UNGC::Application::EMAIL_SENDER], mail.from
  end
end
