class GraceLetterPresenter < CommunicationPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper

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

  def has_files?
    files.any?
  end
  alias_method :has_file?, :has_files?

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
    @cop_file ||= files.first || new_cop_file
  end

  def due_on
    (organization.cop_due_on + grace_period).to_date
  end

  def grace_period
    GraceLetterApplication::GRACE_DAYS
  end

  def language_id
    @language_id ||= cop_file.language_id
  end

  def cop_type
    CopFile::TYPES[:grace_letter]
  end

  def show_partial
    '/shared/cops/show_grace_style'
  end

  alias_method :admin_partial, :show_partial

  def results_partial
  end

  def return_path
    if current_contact.from_organization?
      dashboard_path(tab: :cops)
    else
      admin_organization_path(cop.organization, tab: :cops)
    end
  end

  def full_name
    'Grace Letter'
  end

  private

    def new_cop_file
      CopFile.new(attachment_type: cop_type, language_id: default_language_id)
    end

    def default_language_id
      Language.default_language_id
    end

end
