class SampleCopQuestionnaire
  attr_reader :questionnaire

  def self.create
    new.create_questionnaire
  end

  def create_questionnaire
    create_question_group :verification
    create_question_group :mandatory
    create_question_group :strategy
    PrincipleArea.find_each {|area| create_question_group(:additional, area) }
    create_question_group :un_goals
    create_question_group :governance
    self
  end

  # these questions are hard coded to 2013 for some reason.
  def create_question_group(grouping, area = nil)
    question = create(:cop_question,
                      grouping: grouping,
                      year: 2013,
                      principle_area: area,
                      text: "#{grouping} question")
    create(:cop_attribute, cop_question: question,
           open: true, text: "#{grouping} open")
    create(:cop_attribute, cop_question: question,
           open: false, text: "#{grouping} option")
  end

  private

  def create(*args)
    FactoryGirl.create(*args)
  end

end

