require 'test_helper'

class CopSubmissionTest < ActionDispatch::IntegrationTest

  # check for a question in each group
  # check for

  test "handle COP submission lifecycle" do
    create(:language, name: 'English')
    create_principle_areas
    create_approved_organization_and_user

    # create a questionnaire
    SampleCopQuestionnaire.create

    # from the dashboard page, start a new advanced cop
    dashboard = TestPage::Dashboard.new(@organization_user)
    dashboard.visit
    cop_landing = dashboard.submit_cop
    form = cop_landing.new_advanced_cop

    # Save a draft, an answer is created for each question
    assert_difference 'CopAnswer.count', 18 do
      form.save_draft
    end

    # answers are not duplicated when a 2nd draft is saved
    assert_no_difference 'CopAnswer.count' do
      form.check 'mandatory option'
      form.free_text 'verification open', 'hello there'
      form.save_draft
    end

    # Answers are remembered
    assert form.checked?('mandatory option')
    assert form.filled?('verification open', with: 'hello there')

    # validations are run on Submit
    form.submit
    assert form.has_validation_error? "Attachment can't be blank"

    # We can submit files
    form.submit_sample_pdf language: 'English'

    # After successful submit, we should be taken to the admin/show page
    detail_page = form.submit
    assert detail_page.has_published_notice?

    # TODO
    # check the confirmation info
    # check the public page info
    # check the dashboard index for a new entry
  end

end
