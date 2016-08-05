require 'test_helper'

class Admin::CopsHelperTest < ActionView::TestCase

  setup do
    create(:organization_type)
    create(:organization)
  end

  test "#show_cop_attributes" do
    create_cop_and_answers_for_grouping('additional')
    assert view.show_cop_attributes(@cop, @principle_area).present?
  end

  test "#show_basic_cop_attributes" do
    create_cop_and_answers_for_grouping('basic')
    assert view.show_basic_cop_attributes(@cop, @principle_area).present?
  end

  test "organization contacts are sent to the dashboard" do
    # Given an organization and a contact
    organization = create(:business)
    contact = create(:contact, organization: organization)

    # and the contact is currently logged in
    view.stubs(current_contact: contact)

    assert_equal dashboard_path(tab: :cops), view.cops_path(organization)
  end

  test "show_weps" do
    organization = create(:organization)
    weps = create(:initiative)
    signing = create(:signing, organization: organization, initiative: weps)
    cop = create(:communication_on_progress, organization: organization)
    expected = cop.organization.signatory_of?(:weps)
    assert_equal expected
  end

  test "non-organization user ex. staff or local network, is sent to their organization detail page" do
    organization = create(:business)
    contact = create(:contact)

    view.stubs(current_contact: contact)

    assert_equal admin_organization_path(organization, tab: :cops), view.cops_path(organization)
  end

  test "edit_admin_cop_path_for_grace_letter" do
    cop = create(:grace_letter)
    expected = edit_admin_organization_grace_letter_path(cop.organization_id, cop)
    assert_equal expected, view.edit_admin_cop_path(cop)
  end

  test "edit_admin_cop_path_for_reporting_cycle_adjustment" do
    cop = create(:reporting_cycle_adjustment)
    expected = edit_admin_organization_reporting_cycle_adjustment_path(cop.organization.id, cop.id)
    assert_equal expected, view.edit_admin_cop_path(cop)
  end

  test "edit_admin_communication_on_progress_path" do
    cop = create(:communication_on_progress)
    expected = edit_admin_organization_communication_on_progress_path(cop.organization.id, cop)
    assert_equal expected, view.edit_admin_cop_path(cop)
  end

  test "admin_cop_path_for_grace_letter" do
    cop = create(:grace_letter)
    expected = admin_organization_grace_letter_path(cop.organization_id, cop)
    assert_equal expected, view.admin_cop_path(cop)
  end

  test "admin_cop_path_for_reporting_cycle_adjustment" do
    cop = create(:reporting_cycle_adjustment)
    expected = admin_organization_reporting_cycle_adjustment_path(cop.organization.id, cop.id)
    assert_equal expected, view.admin_cop_path(cop)
  end

  test "admin_communication_on_progress_path" do
    cop = create(:communication_on_progress)
    expected = admin_organization_communication_on_progress_path(cop.organization.id, cop)
    assert_equal expected, view.admin_cop_path(cop)
  end

  private

  def create_cop_and_answers_for_grouping(grouping = nil)
    @principle_area = create(:principle_area)
    @cop = create(:communication_on_progress)
    question = create(:cop_question, principle_area: @principle_area, grouping: grouping)
    attribute = create(:cop_attribute, cop_question: question)
    create(:cop_answer, cop_id: @cop.id, cop_attribute: attribute)
  end

end
