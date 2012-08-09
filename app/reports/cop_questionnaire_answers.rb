class CopQuestionnaireAnswers < SimpleReport

  def records
    CopAnswer.cop_questionnaire_answers
  end

  def render_output
    self.render_xls_in_batches
  end

  def headers
    [
    'answer_id',
    'implementation',
    'grouping',
    'issue_area',
    'cop_id',
    'organization_id',
    'cop_question_id',
    'question_position',
    'criterion',
    'cop_attribute_id',
    'best_practice_position',
    'best_practice',
    'value',
    'cop_attribute_id_covered',
    'differentiation',
    'created_at'
    ]
  end

  def row(record)
    [
    record.id,
    record.implementation,
    record.grouping,
    record.issue_area,
    record.cop_id,
    record.organization_id,
    record.cop_question_id,
    record.question_position,
    record.criterion,
    record.cop_attribute_id,
    record.best_practice_position,
    record.best_practice,
    record.value,
    record.cop_attribute_id_covered,
    record.differentiation,
    record.created_at
    ]
  end

end
