require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  context '#show_cop_attributes and #show_basic_cop_attributes' do
    setup do
      create(:organization_type)
      create(:organization)
    end

    should "#show_cop_attributes" do
      create_cop_and_answers_for_grouping('additional')
      assert show_cop_attributes(@cop, @principle_area).present?
    end

    should "#show_basic_cop_attributes" do
      create_cop_and_answers_for_grouping('basic')
      assert show_basic_cop_attributes(@cop, @principle_area).present?
    end
  end

  test "select_answer_class" do
    assert_equal 'selected_question', select_answer_class(:literally_anything)
    assert_equal 'unselected_question', view.select_answer_class(false)
    assert_equal 'unselected_question', view.select_answer_class(nil)
  end

  test "issue_area_colour_for" do
    issue = create(:issue, name: "Human Rights")
    assert_equal 'human_right', view.issue_area_colour_for(issue.name)
  end

  test "cop_date_range" do
    cop = create(:communication_on_progress,
                 starts_on: Date.new(2016, 8, 14),
                 ends_on: Date.new(2017, 8, 14))
    assert_equal 'August 2016&nbsp;&nbsp;&ndash;&nbsp;&nbsp;August 2017',
      view.cop_date_range(cop)
  end


  private

  def cop
    @org_type ||= create(:organization_type)
    @org ||= create(:organization)
    @cop ||= create(:communication_on_progress)
  end

  def create_cop_and_answers_for_grouping(grouping = nil)
    @principle_area = create(:principle_area)
    @cop = create(:communication_on_progress)
    question = create(:cop_question, principle_area: @principle_area, grouping: grouping)
    attribute = create(:cop_attribute, cop_question: question)
    create(:cop_answer, cop_id: @cop.id, cop_attribute: attribute)
  end
end
