class CommunicationPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper

  def self.create(cop, contact)
    presenter_class = case
    when cop.is_grace_letter?
      GraceLetterPresenter
    when cop.is_reporting_cycle_adjustment?
      ReportingCycleAdjustmentPresenter
    when cop.is_non_business_format?
      CoePresenter
    else
      CopPresenter
    end
    presenter_class.new(cop, contact)
  end

  def format_name
    case
    when format.nil?
      'Unknown'
    when CommunicationOnProgress::FORMAT.key?(format.to_sym)
      CommunicationOnProgress::FORMAT[format.to_sym]
    else
      I18n.t(format, scope: 'communication_on_progress.format')
    end
  end

end
