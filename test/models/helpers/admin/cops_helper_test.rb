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

  test "show_business_for_peace" do
    organization = create(:organization)
    b4p_id = Initiative::FILTER_TYPES[:business4peace]
    b4p = create(:initiative, id: b4p_id)
    create(:signing, organization: organization, initiative: b4p)
    cop = create(:communication_on_progress, organization: organization)
    assert_equal true, view.show_business_for_peace(cop)
  end

  test "show_weps" do
    organization = create(:organization)
    weps_id = Initiative::FILTER_TYPES[:weps]
    weps = create(:initiative, id: weps_id)
    create(:signing, organization: organization, initiative: weps)
    cop = create(:communication_on_progress, organization: organization)
    assert_equal true, view.show_weps(cop)
  end

  test "advanced_cop_answers" do
    cop_question = create(:cop_question)
    cop_attribute = create(:cop_attribute, cop_question: cop_question)
    cop_answer = create(:cop_answer, cop_attribute: cop_attribute)
    assert_equal true, view.advanced_cop_answers(cop_answer)
  end

  test "show_issue_area_coverage_for_principle_area" do
    cop = create(:communication_on_progress)
    principle_area = create(:principle_area, name: 'Human Rights')
    cop_question = create(:cop_question, principle_area: principle_area)
    cop_attribute = create(:cop_attribute, cop_question: cop_question)
    cop_answer = create(:cop_answer, cop_attribute: cop_attribute)
    assert_equal true, view.show_issue_area_coverage(cop, 'human_rights')
  end

  test "issue_area_colour_for" do
    issue = create(:issue, name: "Human Rights")
    assert_equal 'human_right', view.issue_area_colour_for(issue.name)
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

  test "cop_form_partial" do
    cop = create(:communication_on_progress, cop_type: :basic)
    assert_equal 'basic_form', view.cop_form_partial(cop)
  end

  test "cop_date_range" do
    cop = create(:communication_on_progress, starts_on: Date.new(2016, 8, 14), ends_on: Date.new(2017, 8, 14))
    assert_equal 'August 2016&nbsp;&nbsp;&ndash;&nbsp;&nbsp;August 2017', view.cop_date_range(cop)
  end

  test "select_answer_class" do
    assert_equal 'selected_question', select_answer_class(:literally_anything)
    assert_equal 'unselected_question', view.select_answer_class(false)
    assert_equal 'unselected_question', view.select_answer_class(nil)
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
