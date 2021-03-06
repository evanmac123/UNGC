class CoePresenter < CommunicationPresenter
  Partial = '/shared/cops/show_non_business_style'

  FORMATS = {
    :standalone        => "Stand alone document",
    :financial_report  => "Part of an annual (financial) report",
    :other_report      => "Part of another type of report"
  }.freeze

  attr_reader :coe, :contact

  delegate :id,
           :title,
           :published_on,
           :starts_on,
           :ends_on,
           :include_continued_support_statement?,
           :include_measurement?,
           :can_approve?,
           :can_reject?,
           :cop_attributes,
           :is_grace_letter?,
           :is_reporting_cycle_adjustment?,
           :organization,
           :differentiation_level_with_default,
           :is_new_format?,
           :has_time_period?,
           :cop_files,
           :cop_links,
           :format,
           :evaluated_for_differentiation?,
           :differentiation_description,
           :differentiation,
           :is_advanced_programme?,
           :description,
           :is_test_phase_advanced_programme?,
           :additional_questions?,
           :issue_areas_covered,
           to: :coe

  def initialize(coe, contact)
    @coe = coe
    @contact = contact
  end

  # we should remove these methods
  # in favour of letting the view decide which partials to show
  # that may not be possible due to the still very complex COP presenter
  def show_partial
    Partial
  end

  def admin_partial
    Partial
  end

  def results_partial
    Partial
  end

  # should be moved to a service object? we're doing extensive quries
  def questions
    CopQuestion.find(attributes.collect(&:cop_question_id)).
      sort { |x,y| x.grouping <=> y.grouping }
  end

  # more quries for questions
  def attributes
    coe.cop_attributes
      .includes(:cop_question)
      .where(cop_questions: { principle_area_id: nil, grouping: non_business_type })
      .order('cop_attributes.position ASC')
  end

  # supports questions
  def non_business_type
    coe.organization.non_business_type
  end

  # view concerns

  def organization_name
    coe.organization.name
  end

  def acronym
    coe.organization.cop_acronym
  end

  def format
    FORMATS[coe.format.try(:to_sym)] || 'Unknown'
  end

  # model concerns

  def has_links?
    links.any?
  end

  def has_files?
    files.any?
  end

  def links
    coe.cop_links
  end

  def files
    coe.cop_files
  end

  # moving this into the presenter may be too far,
  # perhaps it could move back out to the view, or to a helper.
  def return_path
    if contact.from_organization?
      dashboard_path(tab: :cops)
    else
      admin_organization_path(coe.organization, tab: :cops)
    end
  end

  def delete_path
    admin_organization_communication_on_progress_path(coe.organization, coe.id)
  end

  def full_name
    'Communication on Engagement'
  end

  def self_assessment
    CommunicationOnProgress::SelfAssessment.for(coe)
  end

end
