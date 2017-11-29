# -*- coding: utf-8 -*-
require 'test_helper'

module COP
  class ActiveFormTest < ActionDispatch::IntegrationTest

    setup do
      travel_to DateTime.new(2016, 7, 6, 14, 0, 0)
      # needed to show the public cop detail page
      create(:container, path: '/participation/report')
    end

    teardown do
      travel_back
    end

    test "handle COP submission lifecycle" do
      # Given a noncommunicating Organization and Contact
      create_approved_organization_and_user
      @organization.communication_late!

      # When I visit the dashboard
      dashboard = TestPage::Dashboard.new(@organization_user)
      dashboard.visit

      # Then I should see that my Organization is Non-communicating
      assert_equal dashboard.organization_status, 'Noncommunicating'

      # When I click the new COP button
      landing = dashboard.submit_cop

      # And choose to create a new Active COP
      form = landing.new_active_cop

      # Then I should see the form and when I click on Save draft
      form.save_draft

      # Then I should see a confirmation message
      assert_equal 'The communication draft has been saved', form.flash_text

      # When continue filling out the form
      form.fill_in_title 'Testing COP'
      form.select_format 'Part of an annual (financial) report'
      form.select_start_date 'June', '2016'
      form.select_end_date 'June', '2017'
      form.check_continued_support_statement(true)
      form.check_reference(:human_rights, true)
      form.check_reference(:labour, true)
      form.check_reference(:environment, true)
      form.check_reference(:anti_corruption, true)
      form.check_include_measurement(true)
      form.choose_method_shared_with_stakeholders = 'Both b) and c)'

      # And I click submit
      form.submit

      # Then I should see a validation error
      assert_equal ["Attachment can't be blank"], form.validation_errors

      # When I finish adding the required fields
      form.add_file language: 'English', filename: 'untitled.pdf'

      # And then I click submit
      detail_page = form.submit

      # Then I should see a confirmation message
      assert_equal 'The communication has been published on the Global Compact website', form.flash_text

      # And I should see the detail results
      assert_equal 'GC Active', detail_page.platform
      assert detail_page.include_continued_support_statement?
      assert detail_page.references? :human_rights
      assert detail_page.references? :labour
      assert detail_page.references? :environment
      assert detail_page.references? :anti_corruption
      assert detail_page.include_measurement?
      assert_equal '2016/07/06', detail_page.published_on
      assert_equal 'June 2016 – June 2017', detail_page.time_period
      assert_equal 'Part of an annual (financial) report', detail_page.format

      # When I click on Public version
      public_version = detail_page.click_on_public_version

      # Then I should see the public data
      assert_equal '2016/07/06', public_version.published_on
      assert_equal 'June 2016 – June 2017', public_version.time_period
      assert_equal 'Part of an annual (financial) report', public_version.format

      # When I go back to the dashboard
      dashboard.visit

      # Then I should see that my organization is now Active
      assert_equal dashboard.organization_status, 'Active'

      # And that my new COP is listed in the list of submitted COPs
      assert_not_nil dashboard.find_cop_with_title('Testing COP')

      # And that my draft is gone
      assert_equal 0, dashboard.draft_cop_count
    end

  end
end
