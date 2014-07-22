require 'test_helper'

class ReportingCycleAdjustmentFormTest < ActiveSupport::TestCase

  def to_date_params(date)
    {
      "ends_on(1i)" => date.year,
      "ends_on(2i)" => date.month,
      "ends_on(3i)" => date.day,
    }
  end

  context "given an existing organization and a user" do
    setup do
      create_organization_and_user
      create_language(name: "English")
    end

    context "when a reporting cycle adjustment is submitted" do
      setup do
        @form = ReportingCycleAdjustmentForm.new(@organization)
        @ends_on = @organization.cop_due_on + 1.month
        @params = cop_file_attributes.merge(to_date_params(@ends_on))
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
        assert_equal @ends_on, @organization.cop_due_on.to_date
      end

      should "set reporting cycle adjustment start_on" do
        date = Date.today
        @form.submit(@params)
        assert_equal date, @form.reporting_cycle_adjustment.starts_on.to_date
      end

      should "set reporting cycle adjustment ends_on" do
        date = Date.today #TODO Venu: shouldn't this be @organization.cop_due_on?
        @form.submit(@params)
        assert_equal @ends_on, @form.reporting_cycle_adjustment.ends_on.to_date
      end

    end

    context "when a reporting_cycle_adjustment is updated" do

      setup do
        @ends_on = @organization.cop_due_on + 2.months
        @form = ReportingCycleAdjustmentForm.new(@organization)
        @form.submit(cop_file_attributes.merge(to_date_params(@ends_on)))
      end

      should "set a new language" do
        l = create_language
        @form.update({language_id: l.id})
        assert_equal l, @form.cop_file.language
      end

      should "set a new attachment" do
        attr = {attachment: fixture_file_upload('files/untitled.jpg')}
        @form.update(attr)
        assert_equal attr[:attachment].original_filename, @form.cop_file.attachment_file_name
      end

      should "remove the old attachment" do
        attr = {attachment: fixture_file_upload('files/untitled.jpg')}
        @form.update(attr)
        assert_equal 1, @form.reporting_cycle_adjustment.cop_files.count
      end

      should "not change the organization.cop_due_date" do
        due_date = @form.organization.cop_due_on
        attr = {attachment: fixture_file_upload('files/untitled.jpg')}
        @form.update(attr)
        assert_equal due_date, @form.organization.cop_due_on
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
end
