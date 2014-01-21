require 'test_helper'

class ReportingCycleAdjustmentFormTest < ActiveSupport::TestCase

  context "given an existing organization and a user" do
    setup do
      create_organization_and_user
      create_language(name: "English")
    end

    context "when a reporting cycle adjustment is submitted" do
      setup do
        @form = ReportingCycleAdjustmentForm.new(@organization)
        @params = cop_file_attributes.merge(ends_on: Date.today + 1.month)
      end

      should "save" do
        assert @form.submit(@params), "failed to save"
      end

      should "create a reporting cycle adjustment" do
        assert_difference('CommunicationOnProgress.count', 1) do
          @form.submit(@params)
        end
      end

      should "create a cop file" do
        assert_difference('CopFile.count', 1) do
          @form.submit(@params)
        end
      end

      should "extend organization due date" do
        @form.submit(@params)
        assert_equal Date.today + 1.month, @organization.cop_due_on.to_date
      end

      should "set reporting cycle adjustment start_on" do
        date = Date.today #TODO Venu: shouldn't this be @organization.cop_due_on?
        @form.submit(@params)
        assert_equal date, @form.reporting_cycle_adjustment.starts_on.to_date
      end

      should "set reporting cycle adjustment ends_on" do
        date = Date.today #TODO Venu: shouldn't this be @organization.cop_due_on?
        @form.submit(@params)
        assert_equal date + 1.month, @form.reporting_cycle_adjustment.ends_on.to_date
      end

    end

    # move me to ReportingCycleAdjustmentApplication
    # ApplicationForReportingCycleAdjustment?
    should "be invalid without a cop file" do
      assert false
    end

    should "be invalid without an ends on date" do
      assert false
    end

    should "be invalid with end date over 11 months from the original due date" do
      assert false
    end

    should "be invalid with and end date before today" do
      assert false
    end

    should "only be allowed once" do
    end

    should "be invalid for a delisted organization" do
      assert false
    end

  end
end
