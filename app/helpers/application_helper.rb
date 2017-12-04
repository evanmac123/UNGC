module ApplicationHelper
  def flash_messages_for(*keys)
    keys.collect { |k| content_tag(:div, flash[k], :class => "flash #{k}") if flash[k] }.join.html_safe
  end

  def dashboard_view_only
    yield if current_contact && request.env['PATH_INFO'].include?('admin')
  end

  def link_to_current(name, url, current, opts={})
    link = link_to name, url, opts
    li_options = {}
    li_options[:class] = 'current' if current
    content_tag :li, link, li_options
  end

  def current_year
    Time.current.strftime('%Y').to_i
  end

  def options_for_enum(active_record_enum, scope: nil)
    active_record_enum.keys.map do |value|
      text = if scope.present?
        I18n.t(value, scope: scope)
      else
        value.humanize
      end
      [text, value]
    end
  end

  def search_filter(filter, disabled: false)
    options = {
      label: filter.label,
      filter: filter.key,
      options: filter.options,
      disabled: disabled,
    }

    if filter.child_key
      options[:child_filter] = filter.child_key
    end

    raw render('components/filter_options_list', options)
  end

  def active_filters(search)
    options = {
      active_filters: search.active_filters,
      disabled: search.disabled?
    }

    raw render('components/active_filters_list', options)
  end

  def cop_date_range(cop)
    "#{m_yyyy(cop.starts_on)}&nbsp;&nbsp;&ndash;&nbsp;&nbsp;#{m_yyyy(cop.ends_on)}".html_safe
  end

  def select_answer_class(item)
    # we reuse the classes from the questionnaire
    item ? 'selected_question' : 'unselected_question'
  end

  def show_cop_attributes(cop, principle, selected=false, grouping='additional', initiative=nil)
    query = QuestionnaireResultsQuery.new(cop.id)
    query.only_answered if params[:action] == 'feed'
    query.initiative(initiative)
    query.grouping(grouping)
    query.principle(principle)

    query.run.map do |question, answers|
      render_cop_answers(question, answers)
    end.join.html_safe
  end

  def show_basic_cop_attributes(cop, principle=nil, selected=false, grouping='basic')
    attributes = cop.cop_attributes
                  .where(cop_questions: {principle_area_id: principle, grouping: grouping})
                  .includes(:cop_question)
                  .order('cop_attributes.position ASC')
    questions = CopQuestion.find(attributes.collect &:cop_question_id).sort { |x,y| x.grouping <=> y.grouping }

    questions.collect do |question|
      answers = cop.cop_answers
                .where('cop_attributes.cop_question_id=?', question.id)
                .joins(:cop_attribute)
      render :partial => 'admin/cops/cop_basic_answers', :locals => { :question => question, :answers => answers }
    end.join.html_safe
  end

  def issue_area_colour_for(issue)
    # Human Rights -> human_right
    # Labour -> labour
    issue.gsub(/ /,'').tableize.singularize
  end

  def m_yyyy(date)
    date ? date.strftime('%B %Y') : '&nbsp;'
  end

  private

  def render_cop_answers(question, answers)
    partial = if question.grouping == 'sdgs'
                'admin/cops/cop_answers_sorted'
              else
                'admin/cops/cop_answers'
              end
    render partial: partial, locals: { question: question, answers: answers }
  end

end
