require 'test_helper'

class CopSubmissionTest < ActionDispatch::IntegrationTest

  test "handle COP submission lifecycle" do
    create(:language, name: 'English')
    create_principle_areas
    create_approved_organization_and_user

    create_questionnaire

    login_as(@organization_user)
    visit '/admin/dashboard'
    click_on 'New Communication on Progress'
    click_on 'Submit a GC Advanced COP here'

    # an answer is created for each question
    assert_difference 'CopAnswer.count', 18 do
      click_on 'Save Draft'
    end

    # answers are not duplicated
    assert_no_difference 'CopAnswer.count' do
      check 'mandatory option'
      fill_in 'verification open', with: 'hello there', visible: false
      click_on 'Save Draft'
    end

    # check the page to see if those two options are changed
    page.find_field 'mandatory option', checked: true
    page.find_field 'verification open', with: 'hello there', visible: false

    click_on 'Submit'

    # TODO check validation errors

    log_page

    select 'English', from: 'communication_on_progress_cop_links_attributes_new_cop_language_id'

    filepath = File.absolute_path('./test/fixtures/files/untitled.pdf')
    attach_file('communication_on_progress_cop_files_attributes_0_attachment', filepath)

    click_on 'Submit'

    log_page

    assert page.has_content?('The communication has been published on the Global Compact website')

    # TODO
    # check the confirmation info
    # check the public page info
  end

  private

  def create_questionnaire
    create_question_group :verification
    create_question_group :mandatory
    create_question_group :strategy
    PrincipleArea.find_each {|area| create_question_group(:additional, area) }
    create_question_group :un_goals
    create_question_group :governance
  end

  # these questions are hard coded to 2013 for some reason.
  def create_question_group(grouping, area = nil)
    question = create(:cop_question, grouping: grouping, year: 2013, principle_area: area)
    create(:cop_attribute, cop_question: question, open: true, text: "#{grouping} open")
    create(:cop_attribute, cop_question: question, open: false, text: "#{grouping} option")
  end

  def log_page
    File.open('./public/system/test-cop-submission.html', 'w') do |f|
      f.write(page.html.gsub('display: none;', ''))
    end
  end

end
