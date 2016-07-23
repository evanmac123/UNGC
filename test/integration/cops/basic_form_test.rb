require 'test_helper'

class BasicFormTest < ActionDispatch::IntegrationTest

  setup do
    travel_to Date.new(2016, 7, 6)
  end

  teardown do
    travel_back
  end

  test "handle COP submission lifecycle" do
    create(:language, name: 'English')
    create_principle_areas

    # create a noncommunicating organization and user
    create_approved_organization_and_user
    @organization.communication_late!

    # needed to show the public cop detail page
    create(:container, path: '/participation/report')

    # create a questionnaire
    questionnaire = BasicCopQuestionnaire.create

    # from the dashboard page, start a new basic cop
    dashboard = TestPage::Dashboard.new(@organization_user)
    dashboard.visit
    assert_equal dashboard.organization_status, 'Noncommunicating'

    cop_landing = dashboard.submit_cop
    form = cop_landing.new_basic_cop

    # Save a draft, an answer is created for each question
    assert_difference 'CopAnswer.count', questionnaire.question_count do
      form.save_draft
    end

    # Answer the basic questions
    form.fill_in_title 'Testing COP'
    form.select_start_date 'June', '2016'
    form.select_end_date 'June', '2017'
    form.check_continued_support_statement(false)
    form.check_reference(:human_rights, true)
    form.check_reference(:labour, false)
    form.check_include_measurement(true)

    # Fill out the statement of continued support
    form.fill_question 'ongoing commitment'

    # Human Rights
    form.fill_question 'relevance of human rights'
    form.fill_question 'implement Human Right'
    form.fill_question 'evaluates performance.', tab: 'Human Rights'

    # Labour
    form.fill_question 'relevance of labour rights'
    form.fill_question 'implement labour policies'
    form.fill_question 'evaluates performance.', tab: 'Labour'

    # Environment
    form.fill_question 'relevance of environmental protection'
    form.fill_question 'implement environmental policies'
    form.fill_question 'evaluates environmental performance.'

    # Anti-Corruption
    form.fill_question 'relevance of anti-corruption'
    form.fill_question 'implement anti-corruption'
    form.fill_question 'evaluates anti-corruption performance.'

    # answers are not duplicated when a 2nd draft is saved
    assert_no_difference 'CopAnswer.count' do
      form.save_draft
    end

    # Answers are remembered and displayed to the user
    assert_equal Date.new(2016, 6, 1), form.starts_on
    assert_equal Date.new(2017, 6, 1), form.ends_on
    assert form.include_continued_support_statement? false
    assert_equal true, form.references?(:human_rights)
    assert_equal false, form.references?(:labour)
    assert_nil form.references?(:environment)
    assert_nil form.references?(:anti_corruption)
    assert form.include_measurement?

    # Check the form
    assert_answered(form, 'ongoing commitment')

    # Human Rights
    assert_answered(form, 'relevance of human rights')
    assert_answered(form, 'implement Human Right')
    assert_answered(form, 'evaluates performance.', tab: 'Human Rights')

    # Labour
    assert_answered(form, 'relevance of labour rights')
    assert_answered(form, 'implement labour policies')
    assert_answered(form, 'evaluates performance.', tab: 'Labour')

    # Environment
    assert_answered(form, 'relevance of environmental protection')
    assert_answered(form, 'implement environmental policies')
    assert_answered(form, 'evaluates environmental performance.')

    # Anti-Corruption
    assert_answered(form, 'relevance of anti-corruption')
    assert_answered(form, 'implement anti-corruption')
    assert_answered(form, 'evaluates anti-corruption performance.')

    # After successful submit, we should be taken to the show page
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
    assert_equal 'Stand alone document – Basic COP Template', detail_page.format

    # Public COP page
    public_version = detail_page.click_on_public_version
    assert_equal '2016/07/06', public_version.published_on
    assert_equal 'June 2016 – June 2017', public_version.time_period
    assert_equal 'Stand alone document – Basic COP Template', public_version.format

    # check the dashboard index for a new entry
    dashboard.visit
    # The organization's status is now active
    assert_equal dashboard.organization_status, 'Active'

    # The COP is listed in the list of submitted COPs
    assert_not_nil dashboard.find_cop_with_title('Testing COP')

    # The draft is gone
    assert_equal 0, dashboard.draft_cop_count
  end

  private

  def assert_answered(form, partial_question_text, tab: nil, answer: nil)
    expected = answer || partial_question_text
    actual = form.find_answer_to(partial_question_text, tab: tab)
    assert_equal expected, actual
  end

end
