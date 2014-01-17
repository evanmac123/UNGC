class GraceLetterPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper

  attr_reader :cop, :current_contact

  delegate :id,
           :created_at,
           :starts_on,
           :ends_on,
           :cop_files,
           :organization,
           :can_approve?,
           :can_reject?,
           :title,
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

  def cop_file
    @cop_file ||= files.first || CopFile.new(attachment_type: cop_type)
  end

  def due_on
    (organization.cop_due_on + grace_period).to_date
  end

  def grace_period
    GraceLetterApplication::GRACE_DAYS
  end

  def language_id
    @language_id ||= cop_file.try(:language).try(:id) || Language.for(:english).try(:id)
  end

  def cop_type
    CopFile::TYPES[:grace_letter]
  end

  def show_partial
    '/shared/cops/show_grace_style'
  end

  def results_partial
  end

  def return_path
    if current_contact.from_organization?
      dashboard_path(tab: :cops)
    else
      admin_organization_path(cop.organization, tab: :cops)
    end
  end

end


