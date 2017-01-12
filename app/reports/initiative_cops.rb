class InitiativeCops < SimpleReport

  attr_accessor :date_range, :initiative_name

  def initialize(date_range, initiative_name)
    @date_range = date_range
    @initiative_name = initiative_name
  end

  def records
    CopAnswer.by_initiative(@initiative_name)
             .joins(communication_on_progress: [:organization])
             .where(communication_on_progresses: { published_on: @date_range })
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
