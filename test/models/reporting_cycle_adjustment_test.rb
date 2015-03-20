require 'test_helper'

class ReportingCycleAdjustmentTest < ActiveSupport::TestCase

  context "Reporting Cycle Adjustments" do
    setup do
      create_organization_and_user('approved')
    end

    should "create a cop of type reporting_cycle_adjustment" do
      adjustment = ReportingCycleAdjustment.new(organization: @organization)
      assert adjustment.valid?
    end

  end
end
