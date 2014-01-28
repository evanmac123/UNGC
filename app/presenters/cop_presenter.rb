class CopPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper

  attr_reader :cop, :current_contact

  # this is truely gross amount of delegation
  # ideally, methods that are to do with presentation
  # that are delegated would be moved up into this presenter
  delegate :additional_questions,
           :additional_questions?,
           :can_approve?,
           :can_reject?,
           :cop_answers,
           :cop_attributes,
           :cop_files,
           :cop_links,
           :created_at,
           :description,
           :differentiation,
           :differentiation_description,
           :differentiation_level_public,
           :ends_on,
           :evaluated_for_differentiation?,
           :format,
           :id,
           :include_continued_support_statement?,
           :include_measurement?,
           :is_advanced_lead?,
           :is_advanced_programme?,
           :is_test_phase_advanced_programme?,
           :issue_areas_covered,
           :issue_area_coverage,
           :languages,
           :latest?,
           :meets_advanced_criteria,
           :missing_items?,
           :notable_program?,
           :number_missing_items,
           :organization_business_entity?,
           :principles,
           :questions_missing_answers,
           :references_anti_corruption?,
           :references_environment?,
           :references_human_rights?,
           :references_labour?,
           :starts_on,
           to: :cop

  def initialize(cop, current_contact)
    @cop = cop
    @current_contact = current_contact
  end

  def title
    cop.organization.cop_name
  end

  def acronym
    cop.organization.cop_acronym
  end

  def organization_name
    cop.organization.name
  end

  def return_path
    if current_contact.from_organization?
      dashboard_path(tab: :cops)
    else
      admin_organization_path(cop.organization, tab: :cops)
    end
  end

  def delete_path
    admin_organization_communication_on_progress_path(cop.organization, cop.id)
  end

  # seems like differentiation can be one of
  # "learner", "active", "advanced", "blueprint"
  def admin_partial
    if cop.evaluated_for_differentiation?
      "/shared/cops/show_#{cop.differentiation}_style"
    else
      partial
    end
  end

  def results_partial
    return unless cop.evaluated_for_differentiation?

    # Basic COP template has its own partial to display text responses
    if cop.is_basic?
      '/shared/cops/show_basic_style'
    else
      '/shared/cops/show_differentiation_style'
    end
  end

  def show_partial
    if cop.evaluated_for_differentiation?
      "/shared/cops/show_differentiation_style_public"
    else
      partial
    end
  end

  def triple_learner_for_one_year?
    cop.organization.triple_learner_for_one_year?
  end

  def double_learner?
    cop.organization.double_learner?
  end

  def differentiation_placement
    levels = { 'learner' => "Learner Platform &#x25BA;", 'active' => "GC Active &#x25BA;", 'advanced' => "GC Advanced" }
    html = levels.map do |key, value|
      content_tag :span, value.html_safe, :style => cop.differentiation_level_public == key ? '' : 'color: #aaa'
    end
    html.join(' ').html_safe
  end

  private

    def partial
      if cop.is_basic?
        '/shared/cops/show_basic_style'
      elsif cop.is_new_format?
        '/shared/cops/show_new_style'
      elsif cop.is_legacy_format?
        '/shared/cops/show_legacy_style'
      end
    end

end
