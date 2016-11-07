class SdgCopAnswers < SimpleReport

  def records
    query = <<-SQL
      select  cop_attributes.text as question_text, organizations.name as organization_name, organizations.employees as employees, sector.name as sector, organization_type.name as organization_type, country.name as country,
      from cop_answers
      inner join cop_attributes
      on cop_attributes.id = cop_answers.cop_attribute_id
      inner join cop_questions
      on cop_questions.id = cop_attributes.cop_question_id
      inner join communication_on_progresses
      on communication_on_progresses.id = cop_answers.cop_id
      inner join organizations
      on organizations.id = communication_on_progresses.organization_id
      where cop_questions.id in (#{CopQuestion.sdgs.ids.join(",")})
      and (value = 1 or cop_answers.text <> '')
      order by cop_id
    SQL
    answers = CopAttribute.find_by_sql(query)

    answers = answers.group_by do |answer|
      answer[:organization_name]
    end
    answers.each do |organization_name, answers|
        organization_name
        answers.map {|attr| attr[:question_text] }
    end
  end

  def render_output
    self.render_xls_in_batches
  end

  def headers
    [
      'organization name',
      'sector',
      'organization_type',
      'country',
      'employees',
      'cop type',
      'questions'
    ]
  end

  def rows(record)
    [
      ]
  end
end
