class InitiativeCops < SimpleReport

  attr_accessor :date_range, :initiative_name

  def initialize(options)
    super(options)
    @date_range = parse_date_range(options)
    @initiative_name = options.fetch(:initiative_name).to_s
  end

  def self.initiative_names
    {
      weps: "WEPs",                     # Initiative
      lead: "LEAD",                     # Initiative
      business_peace: "Busines peace",  # Grouping
      human_rights: "Human Rights",     # Principle Area
    }
  end

  def records
    answer = case @initiative_name
    when "weps", "lead"
      CopAnswer.by_initiative(@initiative_name)
    when "business_peace"
      CopAnswer.by_group(@initiative_name)
    when "human_rights"
      human_rights = PrincipleArea.area_for(:human_rights)
      human_rights_question_ids = CopQuestion.where(principle_area: human_rights).pluck(:id)
      CopAnswer.joins(:cop_attribute).where(cop_attributes: {cop_question_id: human_rights_question_ids})
    else
      raise "Unexpected initiative name: #{@initiative_name}"
    end

    answer.joins(communication_on_progress: [:organization])
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

  private

  def parse_date_range(options)
    # Due to serialization from sidekiq, we'll either get a range of dates
    # or a string representing a range of dates.
    # convert it down to a string and parse it back up so we always get
    # what we want.

    range_string = options.fetch(:date_range).to_s

    # 08-Jan-2017..18-Jan-2017
    start_date, end_date = range_string.split("..").map do |str|
      Date.parse(str)
    end
    start_date..end_date
  end

end
