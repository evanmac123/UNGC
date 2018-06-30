require "test_helper"

class AllLogoRequestsTest < ActiveSupport::TestCase

  should "at least execute..." do
    question = create(:cop_question)
    attribute = create(:cop_attribute, cop_question: question)

    cop = create(:communication_on_progress)

    create(:cop_answer,
      communication_on_progress: cop,
      cop_attribute: attribute,
      value: false)

    report = CopQuestionnaireAnswers.new
    assert_nil report.to_a.first.fetch("cop_attribute_id_covered")
  end

end
