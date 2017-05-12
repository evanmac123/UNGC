class DueDiligence::Review::Show < TestPage::Base

  def initialize(current_path)
    pattern = /\d+$/
    @id = pattern.match(current_path)[0]
  end

  def has_organization_name?(name)
    page.has_text? name
  end

  def organization_name
    find('.organization-name').text
  end

  def requester_name
    find('.requester-name').text
  end

  def state
    find('.state-o-meter')['data-state']
  end

  def path
    admin_due_diligence_review_path(@id)
  end

  def comment_nodes
    all('.comments .comment')
  end

  def click_risk_assessment
    click_on t('due_diligence.actions.add_risk_assessment')
    transition_to DueDiligence::RiskAssessment::Edit.new(current_path)
  end

  def click_on_start_risk_assessment
    click_on t('due_diligence.actions.start_risk_assessment')
  end

  def click_legal_recommendations
    click_on t('due_diligence.actions.add_legal_recommendations')
    transition_to DueDiligence::Legal::Edit.new(current_path)
  end

  def click_final_decision
    click_on t('due_diligence.actions.add_final_decision')
    transition_to DueDiligence::FinalDecision::Edit.new(current_path)
  end

  def add_comment(comment)
    fill_in 'Comment', with: comment
    check 'Notify Participant Manager'
    # Send notifications inline so we can query the deliveries array without race conditions
    click_on 'Add comment'
    transition_to DueDiligence::Review::Show.new(current_path)
  end

  def add_document(filename)
    attach_file 'wrong', File.join('test/fixtures/files', filename)
  end

  def email_sent_to_legal?
    ActionMailer::Base.deliveries.any?{|email| email.to == ["integrityteam@unglobalcompact.org"] }
  end

  def email_sent_to_participant_manager?
    ActionMailer::Base.deliveries.any?{|email| email.to == [participant_manager] }
  end

  def participant_manager
    Comment.last.commentable.organization.participant_manager_email
  end

  def has_comment?(comment)
    page.has_text? comment
  end

  def overall_esg_score
    text = find("#esg_score").text
    match = /\d+/.match(text)
    match[0] if match.present?
  end

  def involved_in_tobacco?
    text = find("#involved_in_tobacco").text
    match = /true|false/.match(text)
    match[0] if match.present?
  end

  def highest_controversy_level
    text = find("#highest_controversy_level").text
    match = /\d+/.match(text)
    match[0] if match.present?
  end

  def excluded_by_the_norwegian_fund?
    text = find("#excluded_by_norwegian_pension_fund").text
    match = /true|false/.match(text)
    match[0] if match.present?
  end

  def peak_rri
    text = find("#rep_risk_peak").text
    match = /\d+/.match(text)
    match[0] if match.present?
  end

  def world_check_allegations
    find("#world_check_allegations").text
  end

end
