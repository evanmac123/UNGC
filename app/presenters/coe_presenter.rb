class CoePresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper

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

  # ideally this would be refactored out to views with simple models
  # but it's too risky atm
  def render_questions_and_answers
    questions.collect do |question|
      answers = coe.cop_answers.all(:conditions => ['cop_attributes.cop_question_id=?', question.id], :include => [:cop_attribute])
      render :partial => 'admin/cops/cop_answers', :locals => { :question => question, :answers => answers }
    end.join.html_safe
  end

  # should be moved to a service object? we're doing extensive quries
  def questions
    CopQuestion.find(attributes.collect &:cop_question_id).sort { |x,y| x.grouping <=> y.grouping }
  end

  # more quries for questions
  def attributes
    coe.cop_attributes.all(:conditions => {:cop_questions => {
                                              :principle_area_id => nil,
                                              :grouping => non_business_type}
                                            },
                                        :include    => :cop_question,
                                        :order      => 'cop_attributes.position ASC')
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

end
