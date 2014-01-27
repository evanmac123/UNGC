class ReportingCycleAdjustmentForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :organization, :cop_file, :reporting_cycle_adjustment, :ends_on

  delegate :attachment,
           :attachment_type,
           :language_id,
           to: :cop_file

  validate :validate_ends_on_date
  validates :attachment, presence: true
  validates :attachment_type, presence: true
  validates :language_id, presence: true

  def initialize(organization, reporting_cycle_adjustment = nil)
    @organization = organization
    @reporting_cycle_adjustment = reporting_cycle_adjustment || ReportingCycleAdjustment.new(organization: organization)
  end

  def starts_on
    Date.today
  end

  def cop_file
    @cop_file ||= reporting_cycle_adjustment.cop_files.first || reporting_cycle_adjustment.cop_files.build(attachment_type: ReportingCycleAdjustment::TYPE)
  end

  def has_file?
    reporting_cycle_adjustment.cop_files.any?
  end

  def new_record?
    reporting_cycle_adjustment.new_record?
  end

  def submit(params)
    cop_file.language_id = params[:language_id]
    cop_file.attachment = params[:attachment]
    @ends_on = params[:ends_on].to_date if params[:ends_on]

    if valid?
      ReportingCycleAdjustmentApplication.submit_for(organization, reporting_cycle_adjustment, ends_on)
    end
  end

  def ends_on
    @ends_on ||= reporting_cycle_adjustment.ends_on
  end

  def update(params)
    cop_file.language_id = params[:language_id]
    cop_file.attachment = params[:attachment] if params.has_key?(:attachment)
    @ends_on = reporting_cycle_adjustment.ends_on
    valid? && cop_file.save
  end

  private

    def validate_ends_on_date
      if ends_on.blank? || ends_on > Date.today + ReportingCycleAdjustmentApplication::MAX_MONTHS.months || ends_on < Date.today
        errors.add :ends_on, 'date should be within 11 months from today'
      end
    end
end

