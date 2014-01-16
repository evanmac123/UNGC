require 'test_helper'

class GraceLetterApplicationTest < ActiveSupport::TestCase

  context "Given an admin" do

    setup do
      create_approved_organization_and_user
      @user = @organization_user
      @org = @organization
    end

    context "When a grace letter is applied for" do

      setup do
        @application = GraceLetterApplication.new(@user, @org)
        @old_cop_due_on_date = @org.cop_due_on.to_date
        @grace_letter = @application.submit(create_cop_file)
      end

      should "create a communication on progress" do
        assert_not_nil @grace_letter
        assert @grace_letter.persisted?, "grace letter not saved"
      end

      should "be valid" do
        assert @grace_letter.valid?
      end

      should "be a grace letter" do
        assert @grace_letter.is_grace_letter?
      end

      should "have a cop file" do
        assert_equal 1, @grace_letter.cop_files.count
      end

      should "have the proper title" do
        assert_equal "Grace Letter", @grace_letter.title
      end

      should "extend the organization's cop due date" do
        assert_equal @old_cop_due_on_date + 90, @org.cop_due_on.to_date
      end
    end

    context "When the organization is listed and no grace letter has been submitted" do
      should "be eligible to submit an application for grace" do
        assert GraceLetterApplication.eligible?(@user, @org)
      end
    end

    context "When the organization is delisted" do
      setup do
        @organization.update_attribute(:cop_state, Organization::COP_STATE_DELISTED)
        @application = GraceLetterApplication.new(@user, @org)
      end

      should "not be eligible to submit an application" do
        refute @application.valid?
        refute GraceLetterApplication.eligible?(@user, @org)
      end

      should "include an error message" do
        @application.valid?
        assert_equal 1, @application.errors.count
        first_error_message = @application.errors.first.last
        assert_equal "Cannot submit a grace letter for a delisted organization", first_error_message
      end
    end

    context "the last submission was a grace letter" do
      setup do
        # submit a grace letter
        GraceLetterApplication.new(@user, @org).submit(create_cop_file)
        # create a second one
        @application = GraceLetterApplication.new(@user, @org)
      end

      should "not be eligible to submit an application" do
        refute @application.valid?
        refute GraceLetterApplication.eligible?(@user, @org)
      end

      should "include an error message" do
        @application.valid?
        assert_equal 1, @application.errors.count
        first_error_message = @application.errors.first.last
        assert_equal "Cannot submit two grace letters in a row", first_error_message
      end
    end

  end

end