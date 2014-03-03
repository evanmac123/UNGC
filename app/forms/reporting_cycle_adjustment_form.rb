class ReportingCycleAdjustmentForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Rails.application.routes.url_helpers

  attr_reader :organization, :cop_file, :reporting_cycle_adjustment, :ends_on
  attr_accessor :edit

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
    cop_file.attachment?
  end

  def new_record?
    reporting_cycle_adjustment.new_record?
  end

  def submit(params)
    cop_file.language_id = params[:language_id]
    cop_file.attachment = params[:attachment]

    date_from_form = parse_ends_on(params)
    @ends_on = date_from_form if date_from_form.present?

    if valid?
      ReportingCycleAdjustmentApplication.submit_for(organization, reporting_cycle_adjustment, ends_on)
    end
  end

  def ends_on
    @ends_on ||= reporting_cycle_adjustment.ends_on || organization.cop_due_on
  end

  def default_ends_on
    @default_ends_on ||= starts_on + 11.months
  end

  def update(params)
    cop_file.language_id = params[:language_id]
    cop_file.attachment = params[:attachment] if params.has_key?(:attachment)
    @ends_on = reporting_cycle_adjustment.ends_on
    valid? && cop_file.save
  end

  def return_url
    if edit
      admin_organization_reporting_cycle_adjustment_path(organization.id, reporting_cycle_adjustment.id)
    else
      cop_introduction_path
    end
  end

  private
  
    def validate_ends_on_date
      if ends_on.blank? || ends_on > Date.today + ReportingCycleAdjustmentApplication::MAX_MONTHS.months || ends_on < Date.today
        errors.add :ends_on, "can be extended up to #{ReportingCycleAdjustmentApplication::MAX_MONTHS} months"
      end
    end

    def parse_ends_on(params)
      # unpack rails date ends_on(1i), ends_on(2i), ends_on(3i)...
      keys = 3.times.map {|i| "ends_on(#{i+1}i)"}
      year, month, day = params.slice(*keys).values.map(&:to_i)
      Date.civil(year, month, day) if [year, month, day].all? &:present?
    end
end

