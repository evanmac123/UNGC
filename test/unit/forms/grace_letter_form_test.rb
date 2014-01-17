require 'test_helper'

class GraceLetterFormTest < ActiveSupport::TestCase

  context "given an existing organization and a user" do
    setup do
      create_organization_and_user
    end

    context "when a grace letter is submitted" do
      setup do
        @form = GraceLetterForm.new(@organization)
        @params = valid_grace_letter_attributes.merge(cop_files_attributes: [valid_cop_file_attributes])
      end

      should "save" do
        assert @form.submit(@params), Array(@form.errors).join("  ")
      end

      should "create a grace letter" do
        assert_difference('CommunicationOnProgress.count', 1) do
          @form.submit(@params)
        end
      end

      should "extend organization due date" do
        date = @organization.cop_due_on
        @form.submit(@params)
        assert_equal date + 90.days, @organization.cop_due_on.to_date
      end

      should "set grace letter start_on" do
        date = @organization.cop_due_on
        @form.submit(@params)
        assert_equal date, @form.grace_letter.starts_on.to_date
      end

      should "set grace letter ends_on" do
        date = @organization.cop_due_on
        @form.submit(@params)
        assert_equal date + 90.days, @form.grace_letter.ends_on.to_date
      end

    end

  end
end
