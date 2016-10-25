require 'test_helper'

class CopsHelperTest < ActionView::TestCase

  test "percent_issue_area_coverage" do
    # Given 3 questions
    # each with an attributes
    # and each of those with an answer.
    # 1 in labour
    # 2 in human rights
    # And one of the human rights answers has a positive value

    # when we ask for the issue area coverage for human rights
    # we should get "50%"

    human_rights = PrincipleArea.find_by!(name: 'Human Rights')
    labour = PrincipleArea.find_by!(name: 'Labour')

    cop = create(:communication_on_progress)

    # labour question, remains empty
    labour_q = create(:cop_question, principle_area: labour, grouping: 'additional')
    labour_attr = create(:cop_attribute, cop_question: labour_q)
    create(:cop_answer,
    communication_on_progress: cop,
    cop_attribute: labour_attr,
    value: nil)

    # unanswer human rights question
    hr_q1 = create(:cop_question, principle_area: human_rights, grouping: 'additional')
    hr_q1_attr = create(:cop_attribute, cop_question: hr_q1)
    create(:cop_answer,
    communication_on_progress: cop,
    cop_attribute: hr_q1_attr,
    value: nil)

    # answered human rights question
    hr_q2 = create(:cop_question, principle_area: human_rights, grouping: 'additional')
    hr_q2_attr = create(:cop_attribute, cop_question: hr_q2)
    create(:cop_answer,
    communication_on_progress: cop,
    cop_attribute: hr_q2_attr,
    value: true)

    assert_equal 50, view.percent_issue_area_coverage(cop, :human_rights)
    assert_equal 0, view.percent_issue_area_coverage(cop, :labour)
  end

end
