class ReportingCycleAdjustmentForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :organization, :presenter, :params, :reporting_cycle_adjustment

  delegate :cop_file,
           :language_id,
           :ends_on,
           to: :presenter

  delegate  :id,
            to: :reporting_cycle_adjustment

  validate :validate_ends_on_date
  validate :verify_has_one_file

  def initialize(args={})
    @organization = args.fetch(:organization)
    @params = args.fetch(:params, {})
  end

  def reporting_cycle_adjustment
    @reporting_cycle_adjustment ||= ReportingCycleAdjustment.new(organization: organization)
  end

  def presenter
    @presenter ||= ReportingCycleAdjustmentPresenter.new(reporting_cycle_adjustment, nil)
  end


  def starts_on
    Date.today
  end

  def can_submit?
    true # TODO
  end

  def save
    reporting_cycle_adjustment.attributes = reporting_cycle_adjustment_attributes
    valid? && reporting_cycle_adjustment.save #TODO organizaiton.cop_due_date extension
  end

  private

    def validate_ends_on_date
      if presenter.ends_on.blank? || presenter.ends_on > Date.today + 11.months || presenter.ends_on < Date.today
        errors.add :reporting_cycle_adjustment, 'End date should be within 11 months from today'
      end
    end

    def verify_has_one_file
      unless presenter.has_file?
        errors.add :reporting_cycle_adjustment, 'Please select a PDF file for upload.'
      end
    end

    def reporting_cycle_adjustment_attributes
      params.merge({
        organization: organization,
      })
    end
end

