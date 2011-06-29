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
    html = content_tag(:label, [form.radio_button(field, 'true', :class => options[:class]), options[:yes] || 'Yes'].join, {:class => options[:class]})
    html += content_tag(:label, [form.radio_button(field, 'false', :class => options[:class]), options[:no] || 'No'].join, {:class => options[:class]})
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
    html += label_tag("communication_on_progress_cop_answers_attributes_#{answer_index}_value_true", input_tag + 'Yes')

    input_tag = radio_button_tag("communication_on_progress[cop_answers_attributes][#{answer_index}][value]", 'false', !answer.value)
    html += label_tag("communication_on_progress_cop_answers_attributes_#{answer_index}_value_false", input_tag + 'No')
    
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
      html += hidden_field_tag("communication_on_progress[cop_answers_attributes][#{answer_index}][cop_attribute_id]", answer.cop_attribute_id)
      html += hidden_field_tag("communication_on_progress[cop_answers_attributes][#{answer_index}][value]", "0", :id => nil)
      
      cop_attribute_text_content = answer.cop_attribute.text
      cop_attribute_text_content += '&nbsp;&nbsp;' + image_tag('/images/icons/Info_11x11.png', :style => 'margin-bottom: -2px;', :title => answer.cop_attribute.hint) if answer.cop_attribute.hint.present?
      cop_attribute_text = content_tag(:span, cop_attribute_text_content , :class => 'label_text')
            
      html += label_tag("communication_on_progress_cop_answers_attributes_#{answer_index}_value", (checkbox + cop_attribute_text), :title => answer.cop_attribute.hint)
    
    end
    
    return html
  end
  
  def cop_questions_for(cop, grouping, principle=nil)
    # find questions
    principle_area_id = principle.nil? ? nil : PrincipleArea.send(principle).id
    questions = CopQuestion.questions_for(cop.organization).all(:conditions => {:principle_area_id => principle_area_id,
                                                                                :grouping          => grouping.to_s})
    return questions.collect{|question| output_cop_question(cop, grouping, question)}.join('')
  end
  
  def output_cop_question(cop, grouping, question)

    # if the grouping is basic, then these are text based answers, not yes/no or multiple choice
    if grouping == :basic
      html = ''
      html << content_tag(:p, question.cop_attributes.first.try(:text), :class => 'question_text')
      unless question.cop_attributes.first.hint.blank?
        html << content_tag(:div, 'Suggested topics...', :class => "hint_toggle")
        html << content_tag(:div, question.cop_attributes.first.hint, :class => "hint_text", :style => 'display: none;')
      end
      html << hidden_field_tag("communication_on_progress[cop_answers_attributes][][cop_attribute_id]", question.cop_attributes.first.id)
      html << text_area_tag("communication_on_progress[cop_answers_attributes][][text]", '', { :class => 'cop_answer' })
      return content_tag :fieldset, (content_tag(:legend, content_tag(:span, question.text)) + html)
    end
    
    if question.cop_attributes.count == 1
      # single attribute, this is a yes/no question
      html = true_or_false_cop_attribute(cop, question.cop_attributes.first)
    else
      # multiple options
      html = true_or_false_cop_attributes(cop, question.cop_attributes)
    end
    content_tag :fieldset, (content_tag(:legend, content_tag(:span, question.text)) + html)
  end
  
  # Used to display cop answers on the cop show page
  def show_cop_attributes(cop, principle, selected=false, grouping='additional')
    if principle.nil?
      conditions = ['cop_questions.principle_area_id IS NULL AND cop_questions.grouping=?', grouping]
    else
      conditions = ['cop_questions.principle_area_id=? AND cop_questions.grouping=?', principle, grouping]
    end
    
    attributes = cop.cop_attributes.all(:conditions => conditions,
                                        :include    => :cop_question,
                                        :order      => 'cop_attributes.position ASC') 
                                                                           
    questions = CopQuestion.find(attributes.collect &:cop_question_id).sort { |x,y| x.grouping <=> y.grouping }
    
    # we now have all questions, attributes and answers
    questions.collect do |question|
      answers = cop.cop_answers.all(:conditions => ['cop_attributes.cop_question_id=?', question.id], :include => [:cop_attribute])
      
      # output += " <span style='color: red; font-weight: bold;'>" + question.grouping + "</span>"
      if question.cop_attributes.count > 1
        output = content_tag(:li, question.text, :class => 'question_group')
        output += answers.map{|a|
          content_tag(:li, content_tag(:p, a.cop_attribute.text), :class => "selected_question") if a.value?
        }.compact.join('')
        if params[:action] != 'feed'
          output += answers.map{|a|
            content_tag(:li, content_tag(:p, a.cop_attribute.text), :class => "unselected_question") unless a.value.present? && a.value?
          }.compact.join('')
        end

      else
        output = content_tag(:li, question.text, :class => 'question_group')
        output += content_tag(:p, (answers.first.value? ? 'Yes' : 'No'), :style => 'font-weight: bold;' ) unless answers.first.text.present?
        output += content_tag(:p, answers.first.text) if answers.first.text.present?
      end
      content_tag :ul, output, :class => 'questionnaire'
    end.join
  end
  
  # basic cop answers
  def show_basic_cop_attributes(cop, principle=nil, selected=false, grouping='basic')
    if principle.nil?
      conditions = ['cop_questions.principle_area_id IS NULL AND cop_questions.grouping=?', grouping]
    else
      conditions = ['cop_questions.principle_area_id=? AND cop_questions.grouping=?', principle, grouping]
    end
    
    attributes = cop.cop_attributes.all(:conditions => conditions,
                                        :include    => :cop_question,
                                        :order      => 'cop_attributes.position ASC') 
                                                                           
    questions = CopQuestion.find(attributes.collect &:cop_question_id).sort { |x,y| x.grouping <=> y.grouping }
    
    # we now have all questions, attributes and answers
    questions.collect do |question|
      answers = cop.cop_answers.all(:conditions => ['cop_attributes.cop_question_id=?', question.id], :include => [:cop_attribute])
      output = content_tag(:li, question.text, :class => 'question_group')
      output += answers.map{|a|
              content_tag(:li, content_tag(:p, a.cop_attribute.text), :class => answers.first.text.present? ? 'question_text' : 'unselected_question') 
            }.compact.join('')
      
      # if there are more than one attribute for cop question, then use the following to combine every question/response
      
      # if question.cop_attributes.count > 1
      #   output += answers.map{|a|
      #     content_tag(:li, a.cop_attribute.id, :class => "selected_question")
      #     content_tag(:li, a.cop_attribute.text, :class => "selected_question")
      #     content_tag(:li, a.text) if a.text.present?
      #   }.compact.join('')
      # else
      
      if answers.first.text.present?
        output += content_tag(:li, simple_format(answers.first.text), :class => 'question_response')
      else
        output += content_tag(:li, 'No answer provided.', :class => 'question_response')
      end
      content_tag :ul, output, :class => 'basic_question'
    end.join
  end
  
  def principle_area_display_value(cop, area)
    if cop.send("references_#{area}?") || cop.send("concrete_#{area}_activities?")
      "block"
    else
      "none"
    end
  end
  
  def submission_30_days_before_due?(organization, cop)
    cop.new_record? && organization.cop_due_on < (Date.today + 30.days)
  end
  
  def popup_link_to(text, url)
    link_to text, url, {:popup => ['left=50,top=50,height=600,width=1024,resizable=1,scrollbars=1'], :style => 'display: inline;'}
  end
  
  # Outputs javascript variables that will indicate to cop_form.js
  # how to calculate the COP score
  def organization_javascript_vars(organization)
    vars = []
    vars << "joined_after_july_09 = #{organization.joined_after_july_2009?}"
    vars << "participant_for_more_than_5_years = #{organization.participant_for_over_5_years?}"
    vars.collect{|v| javascript_tag "var #{v};"}.join
  end
  
  # we need to preselect the submission tab
  def form_submitted?(form_submitted)
    javascript_tag "var submitted = #{form_submitted ? 1:0};"
  end
  
  def text_partial(letter)
    content_tag :div, render(:partial => "admin/cops/texts/text_#{letter}"),
      :id => "text_#{letter}", :style => 'display: none'
  end
  
  def principle_tab_display_style(cop, principle)
    css_display_style(cop.send("references_#{principle}?") &&
                        (cop.additional_questions? || cop.notable_program?))
  end
  
  def show_issue_area_coverage(cop, principle_area)
    answer_count, question_count = cop.issue_area_coverage(PrincipleArea.send(principle_area).id, 'additional')
    "#{answer_count} of #{question_count} items"
  end
  
  def percent_issue_area_coverage(cop, principle_area)
    answer_count, question_count = cop.issue_area_coverage(PrincipleArea.send(principle_area).id, 'additional')
    if answer_count.to_i > 0 && question_count.to_i > 0
      ((answer_count.to_f / question_count.to_f) * 100).to_i
    else
      0
    end
  end
  
  def issue_area_colour_for(issue)
    # Human Rights -> human_right
    # Labour -> labour
    issue.gsub(/ /,'').tableize.singularize
  end
  
  def date_range(cop)
    "#{m_yyyy(cop.starts_on)} &ndash; #{m_yyyy(cop.ends_on)}"
  end

  def display_errors_for_cop(cop)
     error_messages = cop.readable_error_messages.map { |error| content_tag :li, error }
     content_tag :ol, error_messages.join
  end
  
  def select_answer_class(item)
    # we reuse the classes from the questionnaire
    item ? 'selected_question' : 'unselected_question'
  end
end
