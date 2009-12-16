module Admin::CopsHelper
  def action_links(cop)
    actions = []
    if current_user.from_ungc?
      actions << link_to('Approve', admin_communication_on_progress_comments_path(cop, :commit => LogoRequest::EVENT_APPROVE.titleize), :method => :post) if cop.can_approve?
      actions << link_to('Reject', admin_communication_on_progress_comments_path(cop.id, :commit => LogoRequest::EVENT_REJECT.titleize), :method => :post) if cop.can_reject?
    end
    links = actions.join(" | ")
    content_tag :p, links unless links.blank?
  end
  
  def true_or_false_field(form, field, options={})
    html = content_tag(:label, [form.radio_button(field, 'true', :class => options[:class]), options[:yes] || 'Yes'].join)
    html << content_tag(:label, [form.radio_button(field, 'false', :class => options[:class]), options[:no] || 'No'].join)
    return html
  end
  
  def true_or_false_cop_attribute(cop, attribute)
    answer = cop.cop_answers.collect do |a| 
      a if a.cop_attribute_id == attribute.id
    end.compact.first
    
    # build html output
    answer_index = cop.cop_answers.index(answer)
    html = hidden_field_tag("communication_on_progress[cop_answers_attributes][#{answer_index}][cop_attribute_id]", answer.cop_attribute_id)
    input_tag = radio_button_tag("communication_on_progress[cop_answers_attributes][#{answer_index}][value]", 'true', answer.value)
    html << label_tag("communication_on_progress_cop_answers_attributes_#{answer_index}_value_true", input_tag + 'Yes')

    input_tag = radio_button_tag("communication_on_progress[cop_answers_attributes][#{answer_index}][value]", 'false', !answer.value)
    html << label_tag("communication_on_progress_cop_answers_attributes_#{answer_index}_value_false", input_tag + 'No')
    
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
      checkbox = check_box_tag("communication_on_progress[cop_answers_attributes][#{answer_index}][value]", '1', answer.value)
      html << hidden_field_tag("communication_on_progress[cop_answers_attributes][#{answer_index}][cop_attribute_id]", answer.cop_attribute_id)
      html << hidden_field_tag("communication_on_progress[cop_answers_attributes][#{answer_index}][value]", "0", :id => nil)
      html << label_tag("communication_on_progress_cop_answers_attributes_#{answer_index}_value", (checkbox + answer.cop_attribute.text))
    end
    
    return html
  end
  
  def cop_questions_for(cop, grouping, principle=nil)
    # find questions
    principle_area_id = principle.nil? ? nil : PrincipleArea.send(principle).id
    questions = CopQuestion.questions_for(cop.organization).all(:conditions => {:principle_area_id => principle_area_id,
                                                                                :grouping          => grouping.to_s})
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
    content_tag :fieldset, (content_tag(:legend, question.text) + html)
  end
  
  # Used to display cop answers on the cop show page
  def show_cop_attributes(cop, principle, selected=false)
    if principle.nil?
      conditions = 'cop_questions.principle_area_id IS NULL'
    else
      conditions = ['cop_questions.principle_area_id=? and area_selected=?', principle, selected]
    end
    attributes = cop.cop_attributes.all(:conditions => conditions,
                                        :include    => :cop_question)
    questions = CopQuestion.find attributes.collect(&:cop_question_id)
    # we now have all questions, attributes and answers
    questions.collect do |question|
      answers = cop.cop_answers.all(:conditions => ['cop_attributes.cop_question_id=?', question.id],
                                    :include    => :cop_attribute)
      output = question.text
      if question.cop_attributes.count > 1
        output << answers.map{|a|
          content_tag(:span, a.cop_attribute.text, :style => (a.value? ? "" : "text-decoration: line-through;"))
        }.join(". ")
      else
        output << answers.first.value.to_s
      end

      content_tag :li, output
    end.join
  end
  
  def principle_area_display_value(cop, area)
    if cop.send("references_#{area}?") || cop.send("concrete_#{area}_activities?")
      "block"
    else
      "none"
    end
  end
end
