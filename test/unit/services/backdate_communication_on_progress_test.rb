require 'test_helper'

class BackdateCommunicationOnProgressTest < ActiveSupport::TestCase

  # TODO check nonbusiness/COEs
  context "Given a non communicating business" do

    setup do
      @due_date = Date.new(2012, 1, 1)
      @on_time = @due_date - 1.month
      @late = @due_date  + 1.month

      create_organization_and_user
    end

    context "with a late communication on progress" do

      setup do
        @cop = create_communication_on_progress starts_on: @late, organization: @organization
        @organization.update_attribute(:cop_due_on, @due_date)
        @organization.communication_late!
        @organization.save!
      end

      context "when it is backdated" do

        setup do
          assert BackdateCommunicationOnProgress.backdate(@cop, @on_time)
        end

        should "now be an active organization" do
          assert_equal 'active', @organization.cop_state
        end

        should "have it's next cop due a year from the back date" do
          assert_equal @on_time + 1.year, @organization.cop_due_on
        end

        should "have a published on date set to the back date" do
          assert_equal @on_time, @cop.published_on
        end

      end

    end

    context "with 2 late communications" do

      setup do
        @earlier = create_communication_on_progress title: 'earlier', starts_on: @late, organization: @organization
        @earlier.update_attribute :created_at, @late

        @even_more_late = @late + 1.year
        @later = create_communication_on_progress title: 'later', starts_on: @even_more_late, organization: @organization
        @later.update_attribute :created_at, @even_more_late

        @organization.update_attribute(:cop_due_on, @due_date)
        @organization.communication_late!
        @organization.save!
      end

      context "when the earlier communication is backdated" do

        setup do
          assert BackdateCommunicationOnProgress.backdate(@earlier, @on_time)
        end

        should "still be a non communicating organization" do
          assert_equal 'noncommunicating', @organization.cop_state
        end

        should "still have the same cop due date" do
          assert_equal @due_date, @organization.cop_due_on.to_date
        end

        should "have a published on date set to the back date" do
          assert_equal @on_time, @earlier.published_on
        end

      end

    end

  end

end
