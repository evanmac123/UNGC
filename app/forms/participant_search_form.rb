class ParticipantSearchForm < FilterableForm
  include Virtus.model
  include FilterMacros

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

  filter :organization_type
  filter :initiative
  filter :country
  filter :sector
  filter :reporting_status

  attr_writer :search_scope

  def disabled?
    active_filters.count >= 5
  end

  def per_page_options
    @per_page_options ||= [
      ["10 per page", 10],
      ["25 per page", 25],
      ["50 per page", 50]
    ]
  end

  def execute
    search_scope.search(escaped_keywords, options)
  end

  def facets
    search_scope.facets('', facet_options)
  end

  protected

  def escaped_keywords
    escape(keywords)
  end

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
    facet_options.merge(
      page: page,
      per_page: per_page_capped,
      order: order,
      with: reject_blanks({
        organization_type_id: organization_types,
        initiative_ids: initiatives,
        country_id: countries,
        sector_ids: sector_filter.effective_selection_set,
        cop_state: reporting_status.map {|state| Zlib.crc32(state)},
      }),
      sql: {
        include: [
          # TODO update includes
          :organization_type,
          :sector,
          :country
        ]
      }
    )
  end

  def facet_options
    {
      indices: ['participant_search_core'],
      max_matches: 20_000,
      facets: [
        :organization_type_id,
        :initiative_ids,
        :country_id,
        :sector_ids,
        :cop_state,
      ],
    }
  end

  def sort_options
    @sort_options ||= {
      'joined_on'     => 'joined_on',
      'name'          => 'name',
      'type'          => 'type_name',
      'sector'        => 'sector_name',
      'country'       => 'country_name'
    }
  end

  def create_reporting_status_filter(options)
    filter = Filters::ReportingStatusFilter.new(reporting_status)
    FacetFilter.new(filter, enabled_facets(:cop_state))
  end

  def search_scope
    @search_scope ||= Organization.participants_only
  end

  class FacetFilter < Filters::FacetFilter
    def include?(option)
      facets.include?(Zlib.crc32(option.id))
    end
  end

end
