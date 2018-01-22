class CommunicationOnProgress::SelfAssessment

  def self.for(cop)
    if cop.type == 'ExpressCop'
      CommunicationOnProgress::ExpressSelfAssessment.new(cop)
    else
      CommunicationOnProgress::SelfAssessment.new(cop)
    end
  end

  def initialize(cop)
    @cop = cop
    @results = []
  end

  def each(&block)
    add_assessments
    @results.each do |key, value|
      yield(key, value)
    end
  end

  def addressed_principle_area_ids
    principle_areas = []
    PrincipleArea::FILTERS.each_pair do |key, value|
      is_addressed = @cop.public_send("references_#{key}?")
      principle_areas << PrincipleArea.area_for(value).id if is_addressed
    end
    principle_areas
  end

  protected

  def add_assessments
    add_include_continued_support_statement
    add_principle_areas
    add_measurement_of_outcomes
    add_advanced_criteria
  end

  private

  def add_include_continued_support_statement
    label = "Includes a CEO statement of continued support for the UN Global Compact and its ten principles"
    @results << [label, @cop.include_continued_support_statement?]
  end

  def add_principle_areas
    PrincipleArea::FILTERS.each_pair do |key, value|
      label = "Description of actions or relevant policies related to #{value}"
      is_present = @cop.public_send("references_#{key}?")
      @results << [label, is_present]
    end
  end

  def add_measurement_of_outcomes
    message = "Includes a measurement of outcomes"
    @results << [message, @cop.include_measurement?]
  end

  def add_advanced_criteria
    if meets_advanced_criteria
      message = "Meets all criteria for the GC Advanced level"
      @results << [message, @cop.meets_advanced_criteria]
    end
  end

  def meets_advanced_criteria
    @cop.evaluated_for_differentiation? && @cop.additional_questions? && @cop.meets_advanced_criteria
  end

end
