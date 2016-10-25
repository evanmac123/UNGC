require 'test_helper'

module COP
  class ReportingCycleAdjustmentFormTest < ActionDispatch::IntegrationTest

    setup do
      travel_to Date.new(2016, 7, 6)
    end

    teardown do
      travel_back
    end

    test "handle COP submission lifecycle" do
      # Given an approved Organization and Contact
      create_approved_organization_and_user

      # And I'm logged in on the dashboard page
      dashboard = TestPage::Dashboard.new(@organization_user)
      dashboard.visit

      # My next COP should be due in a year
      assert_equal '2017-07-06', dashboard.cop_due_date

      # When I click new reporting cycle adjument
      cop_landing = dashboard.submit_cop
      form = cop_landing.new_reporting_cycle_adjustment

      # And I submit the form
      form.submit

      # Then I should see a validation error
      assert_equal [
        'New deadline must be after your current deadline',
        'Attachment can\'t be blank'
      ], form.validation_errors

      # When I add valid inputs
      form.select_ends_on('June', 6, 2018)
      form.select_language('English')
      form.choose_letter('untitled.pdf')

      # And then I resubmit
      form.submit

      # I should see the success message
      assert_equal 'The Reporting Cycle Adjustment has been published on the Global Compact website', form.flash_text

      # And that the cop due date has changed on the dashboard
      dashboard.visit
      assert_equal '2018-06-06', dashboard.cop_due_date
    end

  end
end
