class AdvancedCopQuestionnaire
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
    area_prefix = area.nil? ? "" : "#{area.name.downcase} "
    question = create(:cop_question,
                      grouping: grouping,
                      year: 2013,
                      principle_area: area,
                      text: "#{area_prefix}#{grouping} question")
    create(:cop_attribute, cop_question: question,
           open: true, text: "#{area_prefix}#{grouping} open")
    create(:cop_attribute, cop_question: question,
           open: false, text: "#{area_prefix}#{grouping} option")
  end

  def question_count
    @_question_count ||= CopAttribute.count
  end

  private

  def create(*args)
    FactoryBot.create(*args)
  end

end

