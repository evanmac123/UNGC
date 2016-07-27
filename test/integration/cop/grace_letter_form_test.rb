require 'test_helper'

module COP
  class GraceLetFormTest < ActionDispatch::IntegrationTest

    setup do
      travel_to Date.new(2016, 7, 6)

      create(:language, name: 'English')
      create(:container, path: '/participation/report')
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

      # When I click new grace letter
      cop_landing = dashboard.submit_cop
      form = cop_landing.new_grace_letter

      # Then I should see the projected extended due date
      assert_equal '2017/10/04.', form.extended_due_date

      # And I submit the form
      form.submit

      # Then I should see a validation error
      assert_equal [
        "Attachment can't be blank"
      ], form.validation_errors

      # When I add valid inputs
      form.select_language('English')
      form.choose_letter('untitled.pdf')

      # And then I resubmit
      form.submit

      # I should see the success message
      assert_equal 'The grace letter has been published on the Global Compact website', form.flash_text

      # And that the cop due date has changed on the dashboard
      dashboard.visit
      assert_equal '2017-10-04', dashboard.cop_due_date

    end

  end
end
