module Admin::CopsHelper
  def true_or_false_field(form, field)
    html = tag(:br)
    html << form.radio_button(field, 'true')
    html << form.label(field, 'True', :value => 'true')
    html << tag(:br)
    html << form.radio_button(field, 'false')
    html << form.label(field, 'False', :value => 'false')
    return html
  end
  
  def true_or_false_cop_attribute(cop, attribute)
    answer = cop.cop_answers.collect do |a| 
      a if a.cop_attribute_id == attribute.id
    end.compact.first
    
    # build html output
    answer_index = cop.cop_answers.index(answer)
    html = tag(:br)
    html << hidden_field_tag("communication_on_progress[cop_answers_attributes][#{answer_index}][cop_attribute_id]", answer.cop_attribute_id)

    html << radio_button_tag("communication_on_progress[cop_answers_attributes][#{answer_index}][value]", 'true', answer.value)
    html << label_tag("communication_on_progress_cop_answers_attributes_#{answer_index}_value_true", 'True')
    html << tag(:br)
    html << radio_button_tag("communication_on_progress[cop_answers_attributes][#{answer_index}][value]", 'false', !answer.value)
    html << label_tag("communication_on_progress_cop_answers_attributes_#{answer_index}_value_false", 'False')
    
    return html
  end
  
  def true_or_false_cop_attributes(cop, attributes)
    # get answers for attributes we are interested in
    attributes_ids = attributes.collect(&:id)
    answers = cop.cop_answers.collect do |a| 
      a if attributes_ids.include?(a.cop_attribute_id)
    end.compact
    
    html = ''
    answers.each do |answer|
      answer_index = cop.cop_answers.index(answer)
      html << tag(:br)
      html << hidden_field_tag("communication_on_progress[cop_answers_attributes][#{answer_index}][cop_attribute_id]", answer.cop_attribute_id)

      html << hidden_field_tag("communication_on_progress[cop_answers_attributes][#{answer_index}][value]", "0", :id => nil)
      html << check_box_tag("communication_on_progress[cop_answers_attributes][#{answer_index}][value]", '1', answer.value)
      html << label_tag("communication_on_progress_cop_answers_attributes_#{answer_index}_value", answer.cop_attribute.text)      
    end
    
    return html
  end
  
  def cop_questions_for(cop, principle, selected)
    # find questions
    questions = CopQuestion.questions_for(cop.organization).all(:conditions => {:principle_area_id => PrincipleArea.send(principle).id,
                                                                                :area_selected     => selected})
    return questions.collect{|question| output_cop_question(cop, question)}.join('')
  end
  
  def output_cop_question(cop, question)
    if question.cop_attributes.count == 1
      # single attribute, this is a YES|NO question
      html = true_or_false_cop_attribute(cop, question.cop_attributes.first)
    else
      # multiple options
      html = true_or_false_cop_attributes(cop, question.cop_attributes)
    end
    content_tag :p, question.text + html
  end
end
