require 'test_helper'
require 'ostruct'

class ParticipantsHelperTest < ActionView::TestCase

  should "generate select options for countries" do
    create_country
    assert_not_nil countries_for_select
  end

  context "#iconize" do
    should "create a no_icon icon for communicating organizations" do
      create_organization_and_user
      assert_equal 'no_icon', iconize(@organization)
    end

    should "create an alert icon for non-communicating organizations" do
      type = create_organization_type(:name => 'Company',  :type_property => OrganizationType::BUSINESS)
      deadline = 90.days.from_now.to_date - 1.year
      org = create_organization(cop_due_on: deadline, participant: true, organization_type: type)
      org.communication_late
      assert_equal 'alert_icon', iconize(org)
    end
  end

  context "#display_participant_status" do

    setup do
      create_removal_reason(description: 'Failure to communicate progress')
    end

    should "be Non-Communicating for non-communicating organizations" do
      org = OpenStruct.new(non_comm_dialogue_on: :fake)
      assert_equal "Non-Communicating", display_participant_status(org)
    end

    should "be Active for active" do
      org = OpenStruct.new(cop_state: 'active')
      assert_equal "Active", display_participant_status(org)
    end

    should "be Expelled for an organization that's deslisted for the reason: delisted" do
      org = OpenStruct.new(cop_state: 'delisted', removal_reason: RemovalReason.delisted)
      assert_equal "Expelled", display_participant_status(org)
    end

    should "be Delisted for an organization that's deslisted with no reason given" do
      org = OpenStruct.new(cop_state: 'delisted')
      assert_equal "Delisted", display_participant_status(org)
    end

    should "be Delisted for delisted for other reasons" do
      org = OpenStruct.new(cop_state: 'delisted', removal_reason: 'other')
      assert_equal "Delisted", display_participant_status(org)
    end

    should "be Non-Communicating for noncommunicating state" do
      org = OpenStruct.new(cop_state: 'noncommunicating')
      assert_equal "Non-Communicating", display_participant_status(org)
    end

    should "be unknown for by default" do
      org = OpenStruct.new()
      assert_equal "Unknown", display_participant_status(org)
    end

  end

# 1  def display_cop_status_title(organization)
#     organization.cop_due_on < Date.today ? "#{organization.cop_acronym} deadline passed" : "Next #{organization.cop_acronym} due"
#   end
# 1  def display_cop_status(organization)
#     status = yyyy_mm_dd organization.cop_due_on
#      if organization.cop_state == Organization::COP_STATE_NONCOMMUNICATING
#       if organization.cop_due_on < Date.today
#         status = yyyy_mm_dd(@participant.cop_due_on)
#       end
#     end
#      status.html_safe
#   end
# 1  def display_delisted_title(organization)
#     organization.removal_reason == RemovalReason.delisted ? 'Expelled on' : 'Delisted on'
#   end


end
