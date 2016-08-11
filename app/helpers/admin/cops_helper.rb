module Admin::CopsHelper
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
    questions = @communication_on_progress.cop_questions_for_grouping(grouping, options)
    questions.collect do |question|
      render :partial => 'admin/cops/cop_question', :locals => { :question => question, :grouping => grouping }
    end.join.html_safe
  end

  # Used to display cop answers on the cop show page
  def show_cop_attributes(cop, principle, selected=false, grouping='additional', initiative=nil)
    initiative_id = initiative ? Initiative.id_by_filter(initiative) : nil
    attributes = cop.cop_attributes
                  .where(cop_questions: {:principle_area_id => principle, :grouping => grouping, initiative_id: initiative_id})
                  .includes(:cop_question)
                  .order('cop_attributes.position')
    questions = CopQuestion.find(attributes.collect(&:cop_question_id)).sort { |x,y| x.grouping <=> y.grouping }

    questions.collect do |question|
      answers = cop.cop_answers
                   .where('cop_attributes.cop_question_id=?', question.id)
                   .joins(:cop_attribute)
      render :partial => 'admin/cops/cop_answers', :locals => { :question => question, :answers => answers }
    end.join.html_safe
  end

  # basic cop answers
  def show_basic_cop_attributes(cop, principle=nil, selected=false, grouping='basic')
    attributes = cop.cop_attributes
                  .where(cop_questions: {principle_area_id: principle, grouping: grouping})
                  .includes(:cop_question)
                  .order('cop_attributes.position ASC')
    questions = CopQuestion.find(attributes.collect(&:cop_question_id)).sort { |x,y| x.grouping <=> y.grouping }

    questions.collect do |question|
      answers = cop.cop_answers
                .where('cop_attributes.cop_question_id=?', question.id)
                .joins(:cop_attribute)
      render :partial => 'admin/cops/cop_basic_answers', :locals => { :question => question, :answers => answers }
    end.join.html_safe
  end

  # we need to preselect the submission tab
  def form_submitted?(form_submitted)
    javascript_tag "var submitted = #{form_submitted ? 1:0};"
  end

  def text_partial(letter)
    content_tag :div, render(:partial => "admin/cops/texts/text_#{letter}"),
      :id => "text_#{letter}", :style => 'display: none'
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

  def cop_date_range(cop)
    "#{m_yyyy(cop.starts_on)}&nbsp;&nbsp;&ndash;&nbsp;&nbsp;#{m_yyyy(cop.ends_on)}".html_safe
  end

  def select_answer_class(item)
    # we reuse the classes from the questionnaire
    item ? 'selected_question' : 'unselected_question'
  end

  def show_business_for_peace(cop)
    cop.organization.signatory_of?(:business4peace)
  end

  def show_weps(cop)
    cop.organization.signatory_of?(:weps)
  end

  def edit_admin_cop_path(cop)
    if cop.is_grace_letter?
      edit_admin_organization_grace_letter_path(cop.organization.id, cop.id)
    elsif cop.is_reporting_cycle_adjustment?
      edit_admin_organization_reporting_cycle_adjustment_path(cop.organization.id, cop.id)
    else
      edit_admin_organization_communication_on_progress_path(cop.organization.id, cop.id)
    end
  end

  def admin_cop_path(cop)
    if cop.is_grace_letter?
      admin_organization_grace_letter_path(cop.organization.id, cop)
    elsif cop.is_reporting_cycle_adjustment?
      admin_organization_reporting_cycle_adjustment_path(cop.organization.id, cop)
    else
      admin_organization_communication_on_progress_path(cop.organization.id, cop)
    end
  end

  def cop_form_partial(cop)
    "#{cop.cop_type}_form"
  end

  def cops_path(organization)
    if current_contact.from_organization?
      dashboard_path(tab: :cops)
    else
      admin_organization_path(organization, tab: :cops)
    end
  end

end
