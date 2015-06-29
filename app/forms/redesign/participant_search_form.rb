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

  filter :organization_type
  filter :initiative
  filter :country
  filter :sector
  filter :reporting_status

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
    Organization.participants_only.search(escape(keywords), options)
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
    'joined_on asc'
  end

  def options
    options = {
      organization_type_id: organization_types,
      initiative_ids: initiatives,
      country_id: countries,
      sector_id: sector_filter.effective_selection_set,
      cop_state: reporting_status.map {|state| Zlib.crc32(state)},
    }

    {
      page: page,
      per_page: per_page_capped,
      order: order,
      star: true,
      with: reject_blanks(options),
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
      'country'       => 'country_name'
    }
  end

end
