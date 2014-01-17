require 'test_helper'

class ReportingCycleAdjustmentFormTest < ActiveSupport::TestCase

  context "given an existing organization and a user" do
    setup do
      create_organization_and_user
    end

    context "when a grace letter is submitted" do
      setup do
        @form = ReportingCycleAdjustmentForm.new(
          organization: @organization,
          params: valid_reporting_cycle_adjustment_attributes.merge(
            ends_on: Date.today + 1.month,
            cop_files_attributes: [valid_cop_file_attributes])
          )
      end

      should "create a reporting cycle adjustment" do
        assert_difference('CommunicationOnProgress.count', 1) do
          @form.save
        end
      end

      should "extend organization due date" do
        date = @organization.cop_due_on
        @form.save
        assert_equal date + 1.month, @organization.cop_due_on.to_date
      end

      should "set reporting cycle adjustment start_on" do
        date = Date.today #TODO Venu: shouldn't this be @organization.cop_due_on?
        @form.save
        assert_equal date, @form.reporting_cycle_adjustment.starts_on.to_date
      end

      should "set reporting cycle adjustment ends_on" do
        date = Date.today #TODO Venu: shouldn't this be @organization.cop_due_on?
        @form.save
        assert_equal date + 1.month, @form.reporting_cycle_adjustment.ends_on.to_date
      end

    end

    should "be invalid without a cop file" do
      assert false
    end

    should "be invalid without an ends on date" do
      assert false
    end

    should "be invalid without end date over 11 months" do
      assert false
    end

    should "be invalid without end date before today" do
      assert false
    end

    should "not submit 2 in a row" do
      assert false
    end

    should "not submit for delisted organization" do
      assert false
    end

  end
end
