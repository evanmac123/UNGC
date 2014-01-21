class ReportingCycleAdjustmentForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :organization, :cop_file, :reporting_cycle_adjustment

  delegate :attachment,
           :attachment_type,
           :language_id,
           to: :cop_file

  validate :validate_ends_on_date
  validates :attachment, presence: true
  validates :attachment_type, presence: true
  validates :language_id, presence: true

  def initialize(organization)
    @organization = organization
    @reporting_cycle_adjustment ||= ReportingCycleAdjustment.new(organization: organization)
  end

  def starts_on
    Date.today
  end

  def can_submit?
    true # TODO
  end

  def cop_file
    @cop_file ||= reporting_cycle_adjustment.cop_files.first || reporting_cycle_adjustment.cop_files.build(attachment_type: ReportingCycleAdjustment::TYPE)
  end

  def submit(params)
    cop_file.language_id = params[:language_id]
    cop_file.attachment = params[:attachment]

    if valid?
      ReportingCycleAdjustmentApplication.new(organization).submit(reporting_cycle_adjustment, params[:ends_on])
    end
  end

  private

    def validate_ends_on_date
      ends_on = params[:ends_on]
      if ends_on.blank? || ends_on > Date.today + ReportingCycleAdjustmentApplication::MAX_MONTHS.months || ends_on < Date.today
        errors.add :reporting_cycle_adjustment, 'End date should be within 11 months from today'
      end
    end

    def reporting_cycle_adjustment_attributes
      params.merge({
        organization: organization,
      })
    end
end

