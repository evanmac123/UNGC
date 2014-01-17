require 'test_helper'

class GraceLetterApplicationTest < ActiveSupport::TestCase

  context "Given an admin" do

    setup do
      create_approved_organization_and_user
      @organization
    end

    context "when a grace letter is applied for it" do

      setup do
        @application = GraceLetterApplication.new(@organization)
        @old_cop_due_on_date = @organization.cop_due_on.to_date
        @application.submit(create_cop_file)
        @grace_letter = @application.grace_letter
      end

      should "create an instance of communication on progress" do
        assert_not_nil @grace_letter
        assert @grace_letter.persisted?, "grace letter not saved"
      end

      should "create a grace letter" do
        assert @grace_letter.is_grace_letter?, [Array(@grace_letter.errors).join, @grace_letter.attributes.to_json].join
      end

      should "have a cop file" do
        assert_equal 1, @grace_letter.cop_files.count
      end

      should "have the title 'Grace Letter'" do
        assert_equal "Grace Letter", @grace_letter.title
      end

      should "extend the organization's cop due date" do
        assert_equal @old_cop_due_on_date + 90, @organization.cop_due_on.to_date
      end

      should "have a starts_on date set to the organization's old due date" do
        assert_equal @old_cop_due_on_date, @grace_letter.starts_on.to_date
      end

      should "have an ends_on date set to the organization's new due date" do
        assert_equal @organization.cop_due_on.to_date, @grace_letter.ends_on.to_date
       end

    end

    context "When the organization is listed and no grace letter has been submitted" do
      should "be eligible to submit an application for grace" do
        assert GraceLetterApplication.eligible?(@organization)
      end
    end

    context "When the organization is delisted" do
      setup do
        @organization.update_attribute(:cop_state, Organization::COP_STATE_DELISTED)
        @application = GraceLetterApplication.new(@organization)
      end

      should "not be eligible to submit an application" do
        refute @application.valid?
        refute GraceLetterApplication.eligible?(@organization)
      end

      should "include an error message" do
        @application.valid?
        assert_equal 1, @application.errors.count
        first_error_message = @application.errors.first
        assert_equal "Cannot submit a grace letter for a delisted organization", first_error_message
      end
    end

    context "the last submission was a grace letter" do
      setup do
        GraceLetterApplication.submit(@organization, create_cop_file)
        @application = GraceLetterApplication.new(@organization)
      end

      should "not be eligible to submit an application" do
        refute @application.valid?
        refute GraceLetterApplication.eligible?(@organization)
      end

      should "include an error message" do
        @application.valid?
        assert_equal 1, @application.errors.count
        first_error_message = @application.errors.first
        assert_equal "Cannot submit two grace letters in a row", first_error_message
      end
    end

  end

end