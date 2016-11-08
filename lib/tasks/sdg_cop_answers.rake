desc "all the organization that have answers COP SDGs"
task sdg_cop_orgs: :environment do
  query = <<-SQL
    select  cop_attributes.text as question_text, organizations.name as organization_name
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
    # .includes(communication_on_progress: :organization)
    # .references(communication_on_progress: :organization)
    # .where(cop_attribute_id: sdg_attributes.pluck(:id))
    # .where("value = ? or text <> ''", true)
    # .group(:cop_id)
    # # .group_by do |answer|
    # #   answer.communication_on_progress.organization
    # # end

  answers.each do |organization_name, answers|
    ap(
      organization_name: organization_name,
      questions: answers.map {|attr| attr[:question_text] }
    )
  end

  ap "#{answers.count} respondents"

end
