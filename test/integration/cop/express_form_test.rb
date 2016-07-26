require 'test_helper'

module COP
  class ExpressFormTest < ActionDispatch::IntegrationTest

    setup do
      travel_to Date.new(2016, 7, 6)
      create(:container, path: '/participation/report')
    end

    teardown do
      travel_back
    end

    test "handle COP submission lifecycle" do
      # TODO start with a non communicating organization
      create_approved_organization_and_user

      # And I'm logged in on the dashboard page
      dashboard = TestPage::Dashboard.new(@organization_user)
      dashboard.visit

      # My next COP should be due in a year
      assert_equal '2017-07-06', dashboard.cop_due_date

      # When I click new reporting cycle adjument
      cop_landing = dashboard.submit_cop
      form = cop_landing.new_express_cop

      # And I submit the form
      form.submit

      # Then I should see a validation error
      assert_equal ['All questions must be answered'], form.validation_errors

      # When I add valid inputs
      form.check_continued_support_statement(true)
      form.check_covers_issue_areas(true)
      form.check_include_measurement(true)

      # And then I resubmit
      form.submit

      # I should see the success message
      assert_equal 'The communication has been published on the Global Compact website', form.flash_text

      # And that the cop due date has changed on the dashboard
      dashboard.visit
      assert_equal '2017-07-06', dashboard.cop_due_date

      # TODO
      # Check that the cop is "GC Active"
      # Check that the format is Express
      # Check the self assessment format

      # Highest executive supports and endorses the Ten Principles of the United Nations Global Compact.
      # Action is taken in the areas of human rights, labour, environment and anti-corruption.
      # Outcomes of such activities are monitored.

      # Check that there is an entry in the dashboard list of COPs
      # for this COP.

    end

  end
end
