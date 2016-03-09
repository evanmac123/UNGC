class CommunicationOnProgress::ExpressSelfAssessment < CommunicationOnProgress::SelfAssessment

  protected

  def add_assessments
    @results << ["Endorses The Ten Principles", @cop.endorses_ten_principles]
    @results << ["Covers issue areas", @cop.covers_issue_areas]
    @results << ["Measures outcomes", @cop.measures_outcomes]
  end

end
