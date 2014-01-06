class CoePresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper

  Partial = '/shared/cops/show_non_business_style'

  Formats = {
    :standalone        => "Stand alone document",
    :financial_report  => "Part of an annual (financial) report",
    :other_report      => "Part of another type of report"
  }

  attr_reader :coe, :contact

  delegate :id,
           :created_at,
           :starts_on,
           :ends_on,
           :include_continued_support_statement?,
           :include_measurement?,
           :cop_attributes,
           to: :coe

  def initialize(coe, contact)
    @coe = coe
    @contact = contact
  end

  def non_business_type
    coe.organization.non_business_type
  end

  def show_partial
    Partial
  end

  def admin_partial
    Partial
  end

  def results_partial
    Partial
  end

  def title
    coe.organization.cop_name
  end

  def acronym
    coe.organization.cop_acronym
  end

  def format
    Formats[coe.format.try(:to_sym)] || 'Unknown'
  end

  def has_links?
    coe.cop_links.any?
  end

  def has_files?
    coe.cop_files.any?
  end

  def links
    coe.cop_links
  end

  def files
    coe.cop_files
  end

  def return_path
    if contact.from_organization?
      dashboard_path(tab: :cops)
    else
      admin_organization_path(coe.organization, tab: :cops)
    end
  end

end