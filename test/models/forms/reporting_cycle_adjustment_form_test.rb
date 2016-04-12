require 'test_helper'

class ReportingCycleAdjustmentFormTest < ActiveSupport::TestCase

  context "given an existing organization and a user" do
    setup do
      create_organization_and_user
      create(:language, name: "English")
    end

    context "when a reporting cycle adjustment is submitted" do
      setup do
        @form = ReportingCycleAdjustmentForm.new(@organization)
        @ends_on = @organization.cop_due_on + 1.month
        @params = adjustment_params(ends_on: @ends_on)
      end

      should "save" do
        assert @form.submit(@params), @form.errors.full_messages
      end

      should "create a reporting cycle adjustment" do
        assert_difference('CommunicationOnProgress.count', 1) do
          assert_submits @form, with: @params
        end
      end

      should "create a cop file" do
        assert_difference('CopFile.count', 1) do
          assert_submits @form, with: @params
        end
      end

      should "extend organization due date" do
        assert_submits @form, with: @params
        assert_equal @ends_on, @organization.cop_due_on.to_date
      end

      should "set reporting cycle adjustment start_on" do
        assert_submits @form, with: @params
        assert_equal Date.today, @form.reporting_cycle_adjustment.starts_on.to_date
      end

      should "set reporting cycle adjustment ends_on" do
        assert_submits @form, with: @params
        assert_equal @ends_on, @form.reporting_cycle_adjustment.ends_on.to_date
      end

    end

    context "when a reporting_cycle_adjustment is updated" do

      should "set the new cop_due_on date" do
        adjustment = create_reporting_cycle_adjument_for(@organization)
        form = ReportingCycleAdjustmentForm.new(@organization, adjustment)
        new_due_date = adjustment.ends_on + 5.days
        updated_params = to_date_params(new_due_date)

        assert form.update(updated_params), form.errors.full_messages
        assert_equal new_due_date, adjustment.reload.ends_on
        assert_equal new_due_date, @organization.reload.cop_due_on
      end

    end

    # move me to ReportingCycleAdjustmentApplication
    # ApplicationForReportingCycleAdjustment?
    context "validations" do
      setup do
        @form = ReportingCycleAdjustmentForm.new(@organization)
        @params = cop_file_attributes.merge(to_date_params(Date.today + 1.month))
      end

      should "be invalid without a cop file" do
        params = {language_id: Language.first.id}.merge(to_date_params(Date.today + 1.month))
        refute @form.submit(params)
      end

      should "be invalid without an ends on date" do
        refute @form.submit(cop_file_attributes)
      end

      should "be invalid with end date over 11 months from the original due date" do
        reporting_deadline = to_date_params(@organization.cop_due_on + 12.month)
        refute @form.submit(cop_file_attributes.merge(reporting_deadline))
      end

      should "be invalid with an end date before today" do
        refute @form.submit(cop_file_attributes.merge(to_date_params(Date.today - 1.month)))
      end

      should "be invalid with an end date before the original cop due on date." do
        slightly_in_the_future = @organization.cop_due_on - 1.day
        assert slightly_in_the_future > Date.today
        assert_equal false, @form.submit(cop_file_attributes.merge(to_date_params(slightly_in_the_future)))
      end
    end

  end

  private

  def to_date_params(date)
    {
      "ends_on(1i)" => date.year,
      "ends_on(2i)" => date.month,
      "ends_on(3i)" => date.day,
    }
  end

  def assert_submits(form, with: nil)
    assert form.submit(with), form.errors.full_messages
  end

  def adjustment_params(ends_on: nil)
    cop_file_attributes.
      merge(to_date_params(ends_on)).
      merge(language_id: create(:language).id)
  end

  def create_reporting_cycle_adjument_for(organization)
    ends_on = organization.cop_due_on + 2.months
    form = ReportingCycleAdjustmentForm.new(organization)
    params = adjustment_params(ends_on: ends_on)
    assert_submits form, with: params
    form.reporting_cycle_adjustment
  end

end
