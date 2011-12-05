class CopQuestionnaireAnswers < SimpleReport

  def records
    CommunicationOnProgress.find_by_sql("
    SELECT
      a.id AS answer_id,
      q.implementation,
      q.grouping,
      p.name AS issue_area,
      a.cop_id,
      q.id AS cop_question_id,
      q.position AS question_position,
      q.text AS criterion,
      a.cop_attribute_id,
      c.position AS best_practice_position,
      c.text AS best_practice,
      a.value,
      (SELECT CASE a.value WHEN '1' THEN a.`cop_attribute_id` ELSE '' END) AS cop_attribute_id_covered,
      cop.differentiation,
      a.created_at
    FROM
      cop_answers a
    JOIN
      cop_attributes c ON c.id = a.cop_attribute_id
    LEFT JOIN
      cop_questions q ON q.id = c.cop_question_id
    LEFT JOIN
      communication_on_progresses cop ON a.cop_id = cop.id
    LEFT JOIN
      principles p ON p.id = q.principle_area_id
    WHERE
      a.created_at >= '2011-01-31' AND
      VALUE IS NOT NULL
    ORDER BY
      cop_id, q.position, a.created_at")
  end
    
  def headers
    [ 
    'answer_id',
    'implementation',
    'grouping',
    'issue_area',
    'cop_id',
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
    record.answer_id,
    record.implementation,
    record.grouping,
    record.issue_area,
    record.cop_id,
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