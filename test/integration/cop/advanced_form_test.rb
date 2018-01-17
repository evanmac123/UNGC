# -*- coding: utf-8 -*-
require 'test_helper'

module COP
  class AdvancedFormTest < ActionDispatch::IntegrationTest

    setup do
      travel_to Time.zone.parse("2016-07-06 14:00")
    end

    teardown do
      travel_back
    end

    test "handle COP submission lifecycle" do
      # create a noncommunicating organization and user
      create_approved_organization_and_user
      @organization.communication_late!

      # needed to show the public cop detail page
      create(:container, path: '/participation/report')

      # create a questionnaire
      questionnaire = AdvancedCopQuestionnaire.create

      # from the dashboard page, start a new advanced cop
      dashboard = TestPage::Dashboard.new(@organization_user)
      dashboard.visit
      assert_equal dashboard.organization_status, 'Noncommunicating'

      cop_landing = dashboard.submit_cop
      form = cop_landing.new_advanced_cop

      # Save a draft, an answer is created for each question
      assert_difference 'CopAnswer.count', questionnaire.question_count do
        form.save_draft
      end

      # Answer the basic questions
      form.title = 'Testing COP'
      form.format = 'Stand alone document'
      form.start_date 'June', '2016'
      form.end_date 'June', '2017'
      form.include_continued_support_statement = true
      form.references :human_rights, true
      form.references :labour, true
      form.references :environment, true
      form.references :anti_corruption, true
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
      assert form.include_continued_support_statement? true
      assert_equal true, form.references?(:human_rights)
      assert_equal true, form.references?(:labour)
      assert_equal true, form.references?(:environment)
      assert_equal true, form.references?(:anti_corruption)
      assert form.include_measurement?
      assert_equal 'all_access', form.method_shared_with_stakeholders

      # Finish answering at least one option from each question in the questionnaire
      form.check 'verification option'
      form.check 'strategy option'
      form.check 'un_goals option'
      form.check 'governance option'
      form.check "labour additional option"
      form.check "human rights additional option"
      form.check "environment additional option"
      form.check "anti-corruption additional option"

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

      missing_questions = all(:css, ".unselected_question").map(&:text)
      assert_empty missing_questions

      # Differentiation level tab
      assert_equal 'GC Advanced', detail_page.platform
      assert detail_page.include_continued_support_statement?
      assert detail_page.references? :human_rights
      assert detail_page.references? :labour
      assert detail_page.references? :environment
      assert detail_page.references? :anti_corruption
      assert detail_page.include_measurement?

      # Detailed results tab
      assert_equal '2016/07/06', detail_page.published_on
      assert_equal 'June 2016 – June 2017', detail_page.time_period

      # TODO:
      # Files untitled.pdf (English)
      # Links http://example.com (English)

      assert_equal 'Stand alone document', detail_page.format

      # Public COP page
      public_version = detail_page.click_on_public_version
      assert_equal '2016/07/06', public_version.published_on
      assert_equal 'June 2016 – June 2017', public_version.time_period
      assert_equal 'Stand alone document', public_version.format

      # check the dashboard index for a new entry
      dashboard.visit

      # The organization's status is now active
      assert_equal dashboard.organization_status, 'Active'

      # The COP is listed in the list of submitted COPs
      assert_not_nil dashboard.find_cop_with_title('Testing COP')

      # The draft is gone
      assert_equal 0, dashboard.draft_cop_count
    end

  end
end
