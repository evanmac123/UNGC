class ReportingCycleAdjustmentPresenter
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

  def cop_file
    files.first || CopFile.new(attachment_type: cop_type)
  end

  def language_id
    @language_id ||= Language.for(:english).try(:id)
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

end
