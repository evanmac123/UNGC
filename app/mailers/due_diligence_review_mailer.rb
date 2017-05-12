class DueDiligenceReviewMailer < ActionMailer::Base
  include ActionView::Helpers::SanitizeHelper

  default from: UNGC::Application::EMAIL_SENDER

  def new_review_for_research(review_id, requester)
    @review = DueDiligence::Review.find(review_id)
    @requester = requester

    raise "Review state must be :in_review but is #{@review.state}" unless @review.in_review?

    mail \
      to:      integrity_team_emails,
      subject: common_subject("New Due Diligence Request fors")
  end

  def new_review_for_integrity_decision(review_id, contact)
    @review = DueDiligence::Review.find(review_id)
    @contact = contact

    raise "Review state must be :integrity_review but is #{@review.state}" unless @review.integrity_review?

    mail \
      to:      integrity_manager_emails,
      subject: common_subject("Integrity Decision Requested")
  end

  def integrity_decision_rendered(review_id, contact)
    @review = DueDiligence::Review.find(review_id)
    @contact = contact

    raise "Review state must be :engagement_review or :rejected but is #{@review.state}" \
        unless %w[engagement_review rejected].include?(@review.state)

    mail \
      to:      @review.requester.email,
      subject: common_subject("Integrity Decision Rendered")
  end

  def engagement_decision_rendered(review_id, contact)
    @review = DueDiligence::Review.find(review_id)
    @contact = contact

    raise "Review state must be :engaged or :declined but is #{@review.state}" \
        unless %w[engaged declined].include?(@review.state)

    mail \
      to:      integrity_team_emails,
      subject: common_subject("Engagement Decision Rendered")
  end

  def comment_notifier(comment_id, notify_participant_manager = false)
    comment_model = Comment.find(comment_id)
    @comment = CommentPresenter.new(comment_model)
    recipients = notify_participant_manager ? @comment.participant_manager_email : 'integrityteam@unglobalcompact.org'
    mail \
      to:      recipients,
      subject: "#{@comment.contact_name} commented on #{@comment.organization_name}'s Due Diligence Review"
  end

  private

  def integrity_manager_emails
    Contact
        .joins(:roles)
        .where(roles: { name: Role::FILTERS[:integrity_manager]})
        .pluck(:email) ||
        'integrityteam@unglobalcompact.org'
  end

  def integrity_team_emails
    Contact
        .joins(:roles)
        .where(roles: { name: [Role::FILTERS[:integrity_team_member], Role::FILTERS[:integrity_manager]]})
        .pluck(:email) ||
        'integrityteam@unglobalcompact.org'
  end

  def common_subject(prefix)
    individual = " (#{@review.individual_subject})" if @review.individual_subject.present?
    "#{prefix} for #{@review.level_of_engagement.humanize}#{individual} - #{@review.organization.name}"
  end
end
