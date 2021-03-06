  # rails runner 'RenameCopQuestions.new.run' -e production

class RenameCopQuestions
  def run

    new_text = "Any relevant policies, procedures, and activities that the company plans to undertake by its next COP to fulfill this criterion, including goals, timelines, metrics, and responsible staff"
    attributes = CopAttribute.where text: "Any relevant policies, procedures, and activities that the company plans to undertake to fulfill this criterion, including goals, timelines, metrics, and responsible staff"

    # get question groups for cop attributes
    cop_question_ids = attributes.map &:cop_question_id
  
    cop_question_ids.each do |cop_question_id|
      question = CopQuestion.find(cop_question_id)

      # reorder attributes under the question group
      question.cop_attributes.each do |cop_attribute|
        cop_attribute.update_attribute :position, cop_attribute.position - 1
      end

    end
  
    # rename the question and place it last
    attributes.each do |cop_attribute|
      cop_attribute.update_attribute :text, new_text
      new_position = cop_attribute.cop_question.cop_attributes.count
      cop_attribute.update_attribute :position, new_position
    end

    new_text_external = "The COP describes any action(s) that the company plans to undertake by its next COP to have the credibility of the information in its COP externally assessed, including goals, timelines, metrics, and responsible staff"
    attributes_external = CopAttribute.where text: "The COP describes any action(s) that the company plans to undertake to have the credibility of information in its COP externally assessed, including goals, timelines, metrics, and responsible staff"

    # get question groups for cop attributes external question
    cop_question_ids = attributes_external.map &:cop_question_id
  
    cop_question_ids.each do |cop_question_id|
      question = CopQuestion.find(cop_question_id)

      # reorder attributes under the question group
      question.cop_attributes.each do |cop_attribute|
        cop_attribute.update_attribute :position, cop_attribute.position - 1
      end

    end
  
    # rename the question and place it last
    attributes_external.each do |cop_attribute|
      cop_attribute.update_attribute :text, new_text_external
      new_position = cop_attribute.cop_question.cop_attributes.count
      cop_attribute.update_attribute :position, new_position
    end

  
  end
end
