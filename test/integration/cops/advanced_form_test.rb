require 'test_helper'

class CopSubmissionTest < ActionDispatch::IntegrationTest

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

    # Answer the basic questions
    form.format = 'Stand alone document'
    form.start_date 'June', '2016'
    form.end_date 'June', '2017'
    form.include_continued_support_statement = false
    form.references :human_rights, true
    form.references :labour, false
    form.include_measurement = true
    form.method_shared_with_stakeholders = 'COP is easily accessible to all interested parties (e.g. via its website)'

    # answers are not duplicated when a 2nd draft is saved
    assert_no_difference 'CopAnswer.count' do
      form.check 'mandatory option'
      form.free_text 'verification open', 'hello there'
      form.save_draft
    end

    # Answers are remembered
    assert form.checked?('mandatory option')
    assert form.filled?('verification open', with: 'hello there')
    assert_equal 'standalone', form.format
    assert_equal Date.new(2016, 6, 1), form.starts_on
    assert_equal Date.new(2017, 6, 1), form.ends_on
    assert form.include_continued_support_statement? false
    assert_equal true, form.references?(:human_rights)
    assert_equal false, form.references?(:labour)
    assert_nil form.references?(:environment)
    assert_nil form.references?(:anti_corruption)
    assert form.include_measurement?
    assert_equal 'all_access', form.method_shared_with_stakeholders

    # validations are run on Submit
    form.submit
    assert form.has_validation_error? "Attachment can't be blank"

    # We can submit files
    form.add_file language: 'English', filename: 'untitled.pdf'

    # And links
    form.add_link language: 'English', url: 'http://example.com'

    # After successful submit, we should be taken to the admin/show page
    detail_page = form.submit
    assert detail_page.has_published_notice?

    # log_page

    # TODO
    # check the confirmation info
    # check the public page info
    # check the dashboard index for a new entry
  end

  private

  def log_page(filename)
    path = "./public/system/#{filename}"
    File.open(path, 'w') do |f|
      f.write(page.html.gsub('display: none;', ''))
    end
    system "open http://localhost:3000/system/#{filename}"
  end

end
