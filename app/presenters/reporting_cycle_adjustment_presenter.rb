class ReportingCycleAdjustmentPresenter < CommunicationPresenter

  attr_reader :cop, :current_contact

  delegate :id,
           :published_on,
           :starts_on,
           :ends_on,
           :cop_files,
           :organization,
           :can_approve?,
           :can_reject?,
           :is_grace_letter?,
           :is_reporting_cycle_adjustment?,
           :organization,
           :title,
           :differentiation,
           :differentiation_level_with_default,
           :is_new_format?,
           :has_time_period?,
           to: :cop

  def initialize(cop, current_contact)
    @cop = cop
    @current_contact = current_contact
  end

  def has_file?
    files.any? && files.all? { |f| f.valid? }
  end

  def files
    cop.cop_files
  end

  def organization_name
    organization.name
  end

  def acronym
    organization.cop_acronym
  end

  def cop_file
    files.first || CopFile.new(attachment_type: cop_type)
  end

  def language_id
    Language.default_language_id
  end

  def cop_type
    ReportingCycleAdjustment::REPORT_CYCLE_ADJUSTMENT
  end

  def return_path
    if current_contact.from_organization?
      dashboard_path(tab: :cops)
    else
      admin_organization_path(cop.organization, tab: :cops)
    end
  end

  def show_partial
    '/shared/cops/show_reporting_style'
  end

  alias_method :admin_partial, :show_partial

  def results_partial
  end

  def full_name
    'Reporting Cycle Adjustment'
  end

end
