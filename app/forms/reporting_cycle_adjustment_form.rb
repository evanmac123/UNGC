class ReportingCycleAdjustmentForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :organization, :presenter, :params, :reporting_cycle_adjustment

  delegate :cop_file,
           :language_id,
           to: :presenter
  delegate  :id,
            to: :reporting_cycle_adjustment

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

  def can_submit?
    true
  end

  def save
    reporting_cycle_adjustment.attributes = reporting_cycle_adjustment_attributes
    valid? && reporting_cycle_adjustment.save #TODO add extend
  end

  private
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

