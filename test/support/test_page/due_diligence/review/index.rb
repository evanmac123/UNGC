class DueDiligence::Review::Index < TestPage::Base

  def path
    admin_due_diligence_reviews_path
  end

  def new_review
    first("a", text: I18n.t('due_diligence.actions.new_review')).click
    DueDiligence::Review::New.new
  end

  def click_on_organization(organization_name)
    organization_row = all('table.dashboard_table.reviews_table tr.review').detect do |row|
      row.find('td.name')[:title] == organization_name
    end
    organization_row.find(".actions a.edit").click
    transition_to DueDiligence::Review::Show.new(current_path)
  end

end

