class SdgCopAnswers < SimpleReport

  def records
    CopAnswer.joins(communication_on_progress: [:organization],
                    cop_attribute: [:cop_question]).
    includes(communication_on_progress: [{ organization: [:sector, :country, :organization_type] }],
             cop_attribute: [:cop_question ]).
    where("value = 1 or cop_answers.text <> ''").
    where("grouping = 'sdgs'").
    order(:cop_id).
    group_by do |answer|
      answer.communication_on_progress
    end
  end

  def render_output
    self.render_xls
  end

  def headers
    [
      'organization id',
      'organization name',
      'cop id',
      'cop type',
      'cop published on',
      'question + selected sdgs',
      'free text answer',
      'organizaton type',
      'country',
      'sector',
      'employees'
    ]
  end

  def row(row)
    communication_on_progress, answers = row
    [
      communication_on_progress.organization.id,
      communication_on_progress.organization.name,
      communication_on_progress.id,
      rename_cop_type(communication_on_progress),
      communication_on_progress.published_on,
      combined_text(answers),
      combined_answers(answers),
      communication_on_progress.organization.organization_type_name,
      communication_on_progress.organization.country_name,
      communication_on_progress.organization.sector_name,
      communication_on_progress.organization.employees
    ]
  end

  private

  def rename_cop_type(cop)
    if cop.cop_type == "intermediate"
      "active"
    else
      cop.cop_type
    end
  end

  def combined_answers(answers)
    answers.map do |answer|
      answer.text
    end.reject {|a| a.blank? }.join(", ")
  end

  def combined_text(answers)
    answers.map do |question|
      question.cop_attribute.text
    end.compact.join(",\n")
  end


end
