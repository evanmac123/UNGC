class GraceLetterPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper

  attr_reader :cop, :current_contact
  delegate :id,
           :created_at,
           :starts_on,
           :ends_on,
           :cop_files,
           to: :cop

  def initialize(cop, current_contact)
    @cop = cop
    @current_contact = current_contact
  end

  def admin_partial
    partial
  end

  def show_partial
    partial
  end

  def results_partial
  end

  def title
    cop.organization.cop_name
  end

  def acronym
    cop.organization.cop_acronym
  end

  def return_path
    if current_contact.from_organization?
      dashboard_path(tab: :cops)
    else
      admin_organization_path(cop.organization, tab: :cops)
    end
  end

  private
    def partial
      '/shared/cops/show_grace_style'
    end
end
