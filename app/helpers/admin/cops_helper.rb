module Admin::CopsHelper
  include AdminHelper

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

  # we need to preselect the submission tab
  def form_submitted?(form_submitted)
    javascript_tag "var submitted = #{form_submitted ? 1:0};"
  end

  def text_partial(letter)
    content_tag :div, render(:partial => "admin/cops/texts/text_#{letter}"),
      :id => "text_#{letter}", :style => 'display: none'
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
