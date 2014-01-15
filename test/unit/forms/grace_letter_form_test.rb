require 'test_helper'

class GraceLetterFormTest < ActiveSupport::TestCase

  context "given an existing organization and a user" do
    setup do
      create_organization_and_user
    end

    context "when a grace letter is submitted" do
      setup do
        @form = GraceLetterForm.new(
          organization: @organization,
          params: valid_grace_letter_attributes.merge(cop_files_attributes: [valid_cop_file_attributes])
        )
      end

      should "create a grace letter" do
        assert_difference('CommunicationOnProgress.count', 1) do
          @form.save
        end
      end

      should "extend organization due date" do
        date = @organization.cop_due_on
        @form.save
        assert_equal date + 90.days, @organization.cop_due_on.to_date
      end

      should "set grace letter start_on" do
        date = @organization.cop_due_on
        @form.save
        assert_equal date, @form.grace_letter.starts_on.to_date
      end

      should "set grace letter ends_on" do
        date = @organization.cop_due_on
        @form.save
        assert_equal date + 90.days, @form.grace_letter.ends_on.to_date
      end

    end

    should "be invalid without a cop file" do
    end

    should "not submit 2 in a row" do
    end

    should "not submit for delisted organization" do
    end

  end
end
