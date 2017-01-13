require 'test_helper'

class Admin::CopsHelperTest < ActionView::TestCase

  setup do
    create(:organization_type)
    create(:organization)
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
    b4p_id = Initiative.id_by_filter(:business4peace)
    create(:signing, organization: organization, initiative_id: b4p_id)
    cop = create(:communication_on_progress, organization: organization)
    assert_equal true, view.show_business_for_peace(cop)
  end

  test "show_weps" do
    organization = create(:organization)
    weps_id = Initiative.id_by_filter(:weps)
    create(:signing, organization: organization, initiative_id: weps_id)
    cop = create(:communication_on_progress, organization: organization)
    assert_equal true, view.show_weps(cop)
  end

  test "advanced_cop_answers" do
    cop = create(:communication_on_progress)

    # yuck
    view.instance_variable_set(:@communication_on_progress, cop)

    # given a question
    question = create(:cop_question)

    # with 2 attributes
    attribute = create_list(:cop_attribute, 2, cop_question: question).first

    # one with an answer
    answer = create(:cop_answer, cop_attribute: attribute, communication_on_progress: cop)

    # then i can get the answers out
    array_of_answers = [answer]
    assert_equal array_of_answers, view.advanced_cop_answers(question.cop_attributes)
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

  test 'text_partial' do
    assert_match(/it is important that we keep a history of your annual disclosure in our records./, view.text_partial('b'))
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
