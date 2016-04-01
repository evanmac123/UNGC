class CommunicationOnProgress::ExpressSelfAssessment < CommunicationOnProgress::SelfAssessment

  protected

  def add_assessments
    @results << ["Highest executive supports and endorses the Ten Principles of the United Nations Global Compact.", @cop.endorses_ten_principles]
    @results << ["Action is taken in the areas of human rights, labour, environment and anti-corruption.", @cop.covers_issue_areas]
    @results << ["Outcomes of such activities are monitored.", @cop.measures_outcomes]
  end

end
