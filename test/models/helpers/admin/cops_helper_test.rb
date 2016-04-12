require 'test_helper'

class Admin::CopsHelperTest < ActionView::TestCase

  setup {
    create(:organization_type)
    create(:organization)
  }

  should "#show_cop_attributes" do
    create_cop_and_answers_for_grouping('additional')
    assert show_cop_attributes(@cop, @principle_area).present?
  end

  should "#show_basic_cop_attributes" do
    create_cop_and_answers_for_grouping('basic')
    assert show_basic_cop_attributes(@cop, @principle_area).present?
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
