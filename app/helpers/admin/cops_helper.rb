module Admin::CopsHelper
  def action_links(cop)
    actions = []
    if current_contact.from_ungc?
      actions << link_to('Approve', admin_communication_on_progress_comments_path(cop, :commit => LogoRequest::EVENT_APPROVE.titleize), :method => :post) if cop.can_approve?
      actions << link_to('Reject', admin_communication_on_progress_comments_path(cop.id, :commit => LogoRequest::EVENT_REJECT.titleize), :method => :post) if cop.can_reject?
    end
    links = actions.join(" | ")
    content_tag :p, links unless links.blank?
  end

  def true_or_false_field(form, field, options={})
    html = content_tag(:label, [form.radio_button(field, 'true', :class => options[:class]), options[:yes] || 'Yes'].join.html_safe, {:class => options[:class]})
    html += content_tag(:label, [form.radio_button(field, 'false', :class => options[:class]), options[:no] || 'No'].join.html_safe, {:class => options[:class]})

    html
  end

  # get answers for attributes we are interested in
  def advanced_cop_answers(attributes)
    attributes_ids = attributes.map(&:id)
    @communication_on_progress.cop_answers.select {|a| attributes_ids.include?(a.cop_attribute_id) }
  end

  def render_cop_questions_for(grouping, options={})
    principle_area_id  = PrincipleArea.send(options[:principle]) if options[:principle]
    questions = @communication_on_progress.cop_questions_for_grouping(grouping, options)
    questions.collect do |question|
      render :partial => 'admin/cops/cop_question', :locals => { :question => question, :grouping => grouping }
    end.join.html_safe
  end

  # Used to display cop answers on the cop show page
  def show_cop_attributes(cop, principle, selected=false, grouping='additional')
    attributes = cop.cop_attributes.all(:conditions => {:cop_questions => {:principle_area_id => principle, :grouping => grouping}},
                                        :include    => :cop_question,
                                        :order      => 'cop_attributes.position ASC')
    questions = CopQuestion.find(attributes.collect &:cop_question_id).sort { |x,y| x.grouping <=> y.grouping }

    questions.collect do |question|
      answers = cop.cop_answers.all(:conditions => ['cop_attributes.cop_question_id=?', question.id], :include => [:cop_attribute])
      render :partial => 'admin/cops/cop_answers', :locals => { :question => question, :answers => answers }
    end.join.html_safe
  end

  # basic cop answers
  def show_basic_cop_attributes(cop, principle=nil, selected=false, grouping='basic')
    attributes = cop.cop_attributes.all(:conditions => {:cop_questions => {:principle_area_id => principle, :grouping => grouping}},
                                        :include    => :cop_question,
                                        :order      => 'cop_attributes.position ASC')
    questions = CopQuestion.find(attributes.collect &:cop_question_id).sort { |x,y| x.grouping <=> y.grouping }

    questions.collect do |question|
      answers = cop.cop_answers.all(:conditions => ['cop_attributes.cop_question_id=?', question.id], :include => [:cop_attribute])
      render :partial => 'admin/cops/cop_basic_answers', :locals => { :question => question, :answers => answers }
    end.join.html_safe
  end

  def principle_area_display_value(cop, area)
    cop.send("references_#{area}?") || cop.send("concrete_#{area}_activities?") ? "block" : "none"
  end

  # Outputs javascript variables that will indicate to cop_form.js
  # how to calculate the COP score
  def organization_javascript_vars(organization)
    vars = []
    vars << "joined_after_july_09 = #{organization.joined_after_july_2009?}"
    vars << "participant_for_more_than_5_years = #{organization.participant_for_over_5_years?}"
    vars.collect{|v| javascript_tag "var #{v};"}.join.html_safe
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
     content_tag :ol, error_messages.join.html_safe
  end

  def select_answer_class(item)
    # we reuse the classes from the questionnaire
    item ? 'selected_question' : 'unselected_question'
  end
end
