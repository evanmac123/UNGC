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
    # [
    #   'organization id',
    #   'organization name',
    #   'cop id',
    #   'cop type',
    #   'cop published on',
    #   'question + selected sdgs',
    #   'free text answer',
    #   'organizaton type',
    #   'country',
    #   'sector',
    #   'employees'
    # ]
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
      opportunity_answer.map {|ans| ans},
      priority_answer.map {|ans| ans},
      indicator_answer.map {|ans| ans},
      business_model_answer.map {|ans| ans},
      activity_answer.map {|ans| ans},
      sdg1.map {|ans| ans},
      sdg2.map {|ans| ans},
      sdg3.map {|ans| ans},
      sdg4.map {|ans| ans},
      sdg5.map {|ans| ans},
      sdg6.map {|ans| ans},
      sdg7.map {|ans| ans},
      sdg8.map {|ans| ans},
      sdg9.map {|ans| ans},
      sdg10.map {|ans| ans},
      sdg11.map {|ans| ans},
      sdg12.map {|ans| ans},
      sdg13.map {|ans| ans},
      sdg14.map {|ans| ans},
      sdg15.map {|ans| ans},
      sdg16.map {|ans| ans},
      sdg17.map {|ans| ans}
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

  # def combined_answers(answers)
  #   answers.map do |answer|
  #     answer.text
  #     answer.value
  #   end
  # end
  #
  # def combined_text(answers)
  #   answers.map do |question|
  #     question.cop_attribute.text
  #   end
  # end

  def get_opportunity_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6511
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def opportunity_answer
    results = get_opportunity_answers(records)
    results.map { |answer| answer }
  end

  def get_priorities_answer(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6521
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def priority_answer
    results = get_priorities_answer(records)
    results.map { |answer, v| answer }
  end

  def get_indicators_answer(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6531
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def indicator_answer
    results = get_indicators_answer(records)
    results.map { |answer| answer }
  end

  def get_business_model_answer(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6541
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def business_model_answer
    results = get_business_model_answer(records)
    results.map { |answer| answer }
  end

  def get_activity_answes(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6551
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def activity_answer
    results = get_activity_answes(records)
    results.map { |answer| answer }
  end

  def get_sdg1_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6341
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg1
    results = get_sdg1_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg2_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6351
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg2
    results = get_sdg2_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg3_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6361
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg3
    results = get_sdg3_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg4_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6371
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg4
    results = get_sdg4_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg5_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6381
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg5
    results = get_sdg5_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg6_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6391
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg6
    results = get_sdg6_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg7_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6401
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg7
    results = get_sdg7_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg8_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6411
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg8
    results = get_sdg8_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg9_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6421
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg9
    results = get_sdg9_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg10_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6431
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg10
    results = get_sdg10_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg11_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6441
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg11
    results = get_sdg11_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg12_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6451
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg12
    results = get_sdg12_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg13_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6461
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg13
    results = get_sdg13_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg14_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6471
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg14
    results = get_sdg14_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg15_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6481
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg15
    results = get_sdg15_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg16_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6491
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg16
    results = get_sdg16_answers(records)
    results.map { |answer| answer }
  end

  def get_sdg17_answers(records)
    values = []
    cop_answers = records.values.flatten
    cop_answers.each do |answer|
      if answer.cop_attribute_id == 6501
        values << answer.value
      end
    end
    values.map do |answer|
      answer ? 1:0
    end
  end

  def sdg17
    results = get_sdg17_answers(records)
    results.map { |answer| answer }
  end

end
