class Redesign::ParticipantSearchForm < Redesign::FilterableForm
  include Virtus.model

  attribute :organization_types,  Array[Integer], default: []
  attribute :initiatives,         Array[Integer], default: []
  attribute :countries,           Array[Integer], default: []
  attribute :sectors,             Array[Integer], default: []
  attribute :reporting_status,    Array[String],  default: []
  attribute :keywords,            String,         default: ''
  attribute :page,                Integer,        default: 1
  attribute :per_page,            Integer,        default: 12
  attribute :order,               String
  attribute :sort_field,          String
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
    field = sort_options[sort_field]
    if field
      "#{field} #{sort_direction}"
    else
      default_order
    end

  end

  def default_order
    'joined_on desc'
  end

  def options
    options = {
      organization_type_id: organization_types,
      initiative_ids: initiatives,
      country_id: countries,
      sector_id: sector_filter.effective_selection_set,
      cop_state: reporting_status.map {|state| Zlib.crc32(state)},
    }.reject { |_, value| value.blank? }

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

  def sort_options
    @sort_options ||= {
      'joined_on'     => 'joined_on',
      'name'          => 'name',
      'type'          => 'type_name',
      'sector'        => 'sector_name',
      'country'       => 'country_name',
      'company_size'  => 'company_size',
    }
  end

end
