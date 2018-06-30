class CopQuestionnaireAnswers < SimpleReport

  def records
    CopAnswer.select("cop_answers.id,
                q.implementation,
                q.grouping,
                p.name AS issue_area,
                cop_id,
                o.id as organization_id,
                o.name as organization_name,
                q.id AS cop_question_id,
                q.position AS question_position,
                q.text AS criterion,
                cop_answers.cop_attribute_id,
                c.position AS best_practice_position,
                c.text AS best_practice,
                cop_answers.value,
                (SELECT CASE cop_answers.value WHEN '1' THEN cop_attribute_id ELSE NULL END) AS cop_attribute_id_covered,
                cop.differentiation,
                cop_answers.created_at")
      .joins("JOIN cop_attributes c ON c.id = cop_answers.cop_attribute_id
               LEFT JOIN cop_questions q ON q.id = c.cop_question_id
               LEFT JOIN communication_on_progresses cop ON cop_answers.cop_id = cop.id
               LEFT JOIN organizations o ON o.id = cop.organization_id
               LEFT JOIN principles p ON p.id = q.principle_area_id")
      .where("cop_answers.created_at >= '2011-01-31' AND cop_answers.value IS NOT NULL")
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
    'organization_name',
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
    record.organization_name,
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
