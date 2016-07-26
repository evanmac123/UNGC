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
      # Given a noncommunicating Organization and Contact
      create_approved_organization_and_user
      @organization.communication_late!

      # And I'm logged in on the dashboard page
      dashboard = TestPage::Dashboard.new(@organization_user)
      dashboard.visit

      # Then I should see that my Organization is Non-communicating
      assert_equal dashboard.organization_status, 'Noncommunicating'

      # My next COP should be due in a year
      assert_equal '2017-07-06', dashboard.cop_due_date

      # When I click new express cop
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

      # And I resubmit
      detail_page = form.submit

      # Then I should see the success message
      assert_equal 'The communication has been published on the Global Compact website', form.flash_text

      # And detail about my COP
      assert_equal 'GC Active', detail_page.platform
      assert detail_page.references_express? :endorses_ten_principles
      assert detail_page.references_express? :covers_issue_areas
      assert detail_page.references_express? :measures_outcomes
      assert detail_page.express_include_continued_support_statement?
      assert detail_page.express_include_covers_issue_areas?
      assert detail_page.express_include_measurement?
      assert_equal '2016/07/06', detail_page.published_on
      assert_equal 'June 2016 – June 2017', detail_page.time_period

      # When I click on Public version
      public_version = detail_page.click_on_public_version

      # Then I should see the public data
      assert_equal '2016/07/06', public_version.published_on
      assert_equal 'June 2016 – June 2017', public_version.time_period

      # When I re-visit the dashboard page
      dashboard.visit

      # Then I should see that the COP due date has changed
      assert_equal '2017-07-06', dashboard.cop_due_date

      # And I should see that my organization is now Active
      assert_equal dashboard.organization_status, 'Active'

      # And I should see the COP in my list of COPs
      assert_not_nil dashboard.find_cop_with_title('Express COP???')
    end

  end
end
