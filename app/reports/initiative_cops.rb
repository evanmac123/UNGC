class InitiativeCops < SimpleReport

  attr_accessor :start_year, :start_month, :start_day, :end_year, :end_month, :end_day, :initiative

  def initialize(start_year:, start_month:, start_day:, end_year:, end_month:, end_day:, initiative:)
    @start_year = start_year
    @start_month = start_month
    @start_day = start_day
    @end_year = end_year
    @end_month = end_month
    @end_day = end_day
    @initiative = initiative
  end

  def start_period
    Date.new(@start_year, @start_month, @start_day)
  end

  def end_period
    Date.new(@end_year, @end_month, @end_day)
  end

  def time_range
    start_period..end_period
  end

  def records
    CopAnswer.by_initiative(@initiative)
             .joins(communication_on_progress: [:organization])
             .where(communication_on_progresses: { published_on: time_range })
  end

  def headers
    [
      'Organization Name',
      'Organization Type',
      'Organization Size',
      'Sector',
      'Country',
      'Ownership',
      'COP ID',
      'COP Date',
      'Criteria',
      'Best Practice',
      'Value'
    ]
  end

  def row(record)
    [
      record.communication_on_progress.organization.name,
      record.communication_on_progress.organization.organization_type.name,
      record.communication_on_progress.organization.employees,
      record.communication_on_progress.organization.sector.name,
      record.communication_on_progress.organization.country_name,
      record.communication_on_progress.organization.listing_status_name,
      record.communication_on_progress.id,
      record.communication_on_progress.published_on,
      record.cop_attribute.cop_question.text,
      record.cop_attribute.text,
      record.value ? 1:0
    ]
  end


end
