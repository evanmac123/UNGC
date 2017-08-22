class SdgCopAnswers < SimpleReport

  def records
    CopAnswer.joins(communication_on_progress: [:organization],
                    cop_attribute: [:cop_question]).
    includes(communication_on_progress: [{ organization: [:sector, :country, :organization_type] }],
             cop_attribute: [:cop_question ]).
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
    [
      'Organization ID',
      'Organization Name',
      'COP ID',
      'COP Type',
      'COP Published On',
      'Organization Type',
      'Country',
      'Sector',
      'Employees',
      'Opportunities and responsibilities that one or more SDGs represent to our business',
      'Where the company’s priorities lie with respect to one or more SDGs',
      'Goals and indicators set by our company with respect to one or more',
      'How one or more SDGs are integrated into the company’s business model',
      'The (expected) outcomes and impact of your company’s activities related to the SDGs',
      'If the companies activities related to the SDGs are undertaken in collaboration with other stakeholder',
      'Other established or emerging best practices',
      'SDG 1',
      'SDG 2',
      'SDG 3',
      'SDG 4',
      'SDG 5',
      'SDG 6',
      'SDG 7',
      'SDG 8',
      'SDG 9',
      'SDG 10',
      'SDG 11',
      'SDG 12',
      'SDG 13',
      'SDG 14',
      'SDG 15',
      'SDG 16',
      'SDG 17',
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
      communication_on_progress.organization.organization_type_name,
      communication_on_progress.organization.country_name,
      communication_on_progress.organization.sector_name,
      communication_on_progress.organization.employees,
      combined_text(answers),
      combined_answers(answers),
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

  def first_answer(answers)
    answers.flat_map do |key, value|
      value.map do |cop_answer|
        if cop_answer.cop_attribute_id == 6511
          puts cop_answer.cop_attribute.text
          puts cop_answer.value
        end
      end
    end
  end


end
