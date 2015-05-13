class Redesign::ParticipantSearchForm
  include Virtus.model

  DEFAULT_ORDER = 'joined_on'
  SORT_OPTIONS = {
    'joined_on'     => 'joined_on',
    'name'          => 'name',
    'type'          => 'type_name',
    'sector'        => 'sector_name',
    'country'       => 'country_name',
    'company_size'  => 'company_size',
  }

  attribute :organization_types,  Array[Integer], default: []
  attribute :initiatives,         Array[Integer], default: []
  attribute :countries,           Array[Integer], default: []
  attribute :sectors,             Array[Integer], default: []
  attribute :reporting_status,    Array[String],  default: []
  attribute :keywords,            String,         default: ''
  attribute :page,                Integer,        default: 1
  attribute :per_page,            Integer,        default: 12
  attribute :order,               String
  attribute :sort_field,          String,         default: DEFAULT_ORDER
  attribute :sort_direction,      String,         default: 'asc'

  def initialize(page = 1, params = {})
    super(params)
    self.page = page
  end

  def filters
    [
      type_filter,
      initiative_filter,
      country_filter,
      sector_filter,
      reporting_status_filter,
    ]
  end

  def active_filters
    filters.flat_map(&:selected_options)
  end

  def disabled?
    active_filters.count >= 5
  end

  def type_filter
    @type_filter ||= Filters::OrganizationTypeFilter.new(organization_types)
  end

  def initiative_filter
    @initiative_filter ||= Filters::InitiativeFilter.new(initiatives)
  end

  def country_filter
    @country_filter ||= Filters::CountryFilter.new(countries)
  end

  def sector_filter
    @sector_filter ||= Filters::SectorFilter.new(sectors, sectors)
  end

  def reporting_status_filter
    @reporting_status_filter ||= Filters::ReportingStatusFilter.new(reporting_status)
  end

  def per_page_options
    @per_page_options ||= [
      ["10 per page", 10],
      ["25 per page", 25],
      ["50 per page", 50]
    ]
  end

  def execute
    Organization.participants_only.search(keywords, options)
  end

  def keywords
    Riddle::Query.escape(super)
  end

  private

  def per_page_capped
    cap = per_page_options.map(&:last).max
    [per_page, cap].min
  end

  def order
    field = SORT_OPTIONS.fetch(sort_field, DEFAULT_ORDER)
    "#{field} #{sort_direction}"
  end

  def options
    options = {}

    if organization_types.any?
      options[:organization_type_id] = organization_types
    end

    if initiatives.any?
      options[:initiative_ids] = initiatives
    end

    if countries.any?
      options[:country_id] = countries
    end

    if sectors.any?
      options[:sector_id] = sectors
    end

    if reporting_status.present?
      options[:cop_state] = reporting_status.map {|state| Zlib.crc32(state)}
    end

    {
      page: page,
      per_page: per_page_capped,
      order: order,
      star: true,
      with: options,
      indices: ['participant_search_core'],
      sql: {
        include: [
          # TODO update includes
          :organization_type,
          :sector,
          :country
        ]
      }
    }
  end

end
