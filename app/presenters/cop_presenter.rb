class CopPresenter < CommunicationPresenter

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
           :published_on,
           :description,
           :differentiation,
           :differentiation_description,
           :differentiation_level_public,
           :differentiation_level_with_default,
           :ends_on,
           :evaluated_for_differentiation?,
           :format,
           :id,
           :title,
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
           :questions_missing_answers?,
           :references_anti_corruption?,
           :references_environment?,
           :references_human_rights?,
           :references_labour?,
           :starts_on,
           :is_grace_letter?,
           :is_reporting_cycle_adjustment?,
           :organization,
           :is_new_format?,
           :has_time_period?,
           to: :cop

  def initialize(cop, current_contact)
    @cop = cop
    @current_contact = current_contact
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
    html = %w(learner active advanced).map do |level|
      label = I18n.t(level, scope: 'admin.cop.differentiation_level')
      style = cop.differentiation_level_public == level ? '' : 'color: #aaa'
      content_tag :span, label.html_safe, style: style
    end
    html.join(' ').html_safe
  end

  def full_name
    'Communication on Progress'
  end

  def self_assessment
    CommunicationOnProgress::SelfAssessment.for(cop)
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
