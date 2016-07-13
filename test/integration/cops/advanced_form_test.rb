require 'test_helper'

class CopSubmissionTest < ActionDispatch::IntegrationTest

  setup do
    travel_to Date.new(2016, 7, 6)
  end

  teardown do
    travel_back
  end

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

    # Differentiation level tab
    assert_equal 'GC Learner Platform', detail_page.platform
    refute detail_page.include_continued_support_statement?
    assert detail_page.references? :human_rights
    refute detail_page.references? :labour
    refute detail_page.references? :environment
    refute detail_page.references? :anti_corruption
    assert detail_page.include_measurement?

    # Detailed results tab
    assert_equal '2016/07/06', detail_page.published_on
    assert_equal 'June 2016 – June 2017', detail_page.time_period

    # TODO:
    # Files untitled.pdf (English)
    # Links http://example.com (English)

    assert_equal 'Stand alone document', detail_page.format

    # TODO
    # check the public page info
    # check the dashboard index for a new entry
  end


end
