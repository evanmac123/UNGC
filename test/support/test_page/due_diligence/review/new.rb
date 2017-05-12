class DueDiligence::Review::New < TestPage::Base

  def fill_in_organization_name(name)
    fill_in 'Organization name', with: name
  end

  def select_level_of_engagement(level)
    select level, from: 'Level of engagement'
  end

  def fill_in_additional_information(term)
    fill_in 'review_additional_information', with: term
  end

  def submit
    click_on t('due_diligence.actions.submit_review')
    transition_to DueDiligence::Review::Show.new(current_path)
  end

  def path
    new_admin_due_diligence_review_path
  end

end

