require 'test_helper'

class ReportingCycleAdjustmentApplicationTest < ActiveSupport::TestCase
  context "Given an admin" do

    setup do
      create_approved_organization_and_user
    end

    context "when a reporting cycle adjustment is applied for it" do

      setup do
        @reporting_cycle_adjustment = build(:reporting_cycle_adjustment, organization: @organization)
        @ends_on = Date.today + 1.month
        @application = ReportingCycleAdjustmentApplication.new(@organization)
        @old_cop_due_on_date = @organization.cop_due_on.to_date
        @application.submit(@reporting_cycle_adjustment, @ends_on)
      end

      should "create an instance of communication on progress" do
        assert_not_nil @reporting_cycle_adjustment
        assert @reporting_cycle_adjustment.persisted?, "reporting cycle adjustment not saved"
      end

      should "create a reporting cycle adjustment" do
        failure_message = [Array(@reporting_cycle_adjustment.errors).join, @reporting_cycle_adjustment.attributes.to_json].join
        assert @reporting_cycle_adjustment.is_reporting_cycle_adjustment?, failure_message
      end

      should "have the title 'Reporting Cycle Adjustment'" do
        assert_equal "Reporting Cycle Adjustment", @reporting_cycle_adjustment.title
      end

      should "extend the organization's cop due date" do
        assert_equal @ends_on, @organization.cop_due_on.to_date
      end

      should "have a starts_on date set to Today" do
        assert_equal Date.today, @reporting_cycle_adjustment.starts_on.to_date
      end

      should "have an ends_on date set to the organization's new due date" do
        assert_equal @organization.cop_due_on.to_date, @reporting_cycle_adjustment.ends_on.to_date
      end

      should "report that an adjustment has been made for the organization" do
        assert ReportingCycleAdjustment.has_submitted?(@organization)
      end

      should "have added a reporting cycle adjustment to the organization" do
        assert_includes @organization.communication_on_progresses.map(&:format), @reporting_cycle_adjustment.format
      end

    end

    context "When the organization is listed and no reporting_cycle_adjustment has been submitted" do
      should "be eligible to submit an application for reporting_cycle_adjustment" do
        assert ReportingCycleAdjustmentApplication.eligible?(@organization)
      end
    end

    context "When the organization is delisted" do
      setup do
        @organization.update_attribute(:cop_state, Organization::COP_STATE_DELISTED)
        @application = ReportingCycleAdjustmentApplication.new(@organization)
      end

      should "not be eligible to submit an application" do
        refute @application.valid?
        refute ReportingCycleAdjustmentApplication.eligible?(@organization)
      end

      should "include an error message" do
        @application.valid?
        assert_equal 1, @application.errors.count
        first_error_message = @application.errors.first
        assert_equal "Cannot submit a reporting cycle adjustment for a delisted organization", first_error_message
      end
    end

    context "already submitted a reporting_cycle_adjustment" do
      setup do
        due_date = Date.today + 1.month
        adjustment = build(:reporting_cycle_adjustment, organization: @organization)
        assert ReportingCycleAdjustmentApplication.submit_for(@organization, adjustment, due_date)
        @application = ReportingCycleAdjustmentApplication.new(@organization)
      end

      should "not be eligible to submit an application" do
        refute @application.valid?
        refute ReportingCycleAdjustmentApplication.eligible?(@organization)
      end

      should "include an error message" do
        @application.valid?
        assert_equal 1, @application.errors.count
        first_error_message = @application.errors.first
        assert_equal "Cannot submit more than one reporting cycle adjustment", first_error_message
      end
    end

  end
end
