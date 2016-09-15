class QuestionnaireResultsQuery

  def initialize(cop_id)
    @cop_id = cop_id
  end

  def only_answered
    @only_answered = true
  end

  def initiative(initiative_symbol)
    @initiative_id = Initiative::FILTER_TYPES[initiative_symbol]
  end

  def principle(id)
    @principle_area_id = id
  end

  def grouping(grouping)
    @grouping = grouping
  end

  def run
    answers = CopAnswer.includes(cop_attribute: :cop_question)
    answers = answers.where(value: true) if @only_answered
    answers.where(cop_id: @cop_id)
      .where(cop_questions: {
        principle_area_id: @principle_area_id,
        grouping: @grouping,
        initiative_id: @initiative_id
      })
      .order('cop_attributes.position')
      .group_by do |answer|
        answer.cop_attribute.cop_question
      end
  end

end

