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

  def active_filters

    organization_types = organization_type_options.select(&:selected?)
    initiatives = initiative_options.select(&:selected?)
    countries = country_options.select(&:selected?)

    sector_groups = sector_options.map(&:first).select(&:selected?)
    sectors = sector_options.flat_map do |group, sectors|
      sectors.select(&:selected?)
    end

    reporting_statuses = reporting_status_options.select(&:selected?)

    [organization_types, initiatives, countries, sector_groups, sectors, reporting_statuses].flatten
  end

  def disabled?
    active_filters.count >= 5
  end

  def organization_type_options
    pluck_options(OrganizationType.all, :organization_type, organization_types)
  end

  def initiative_options
    pluck_options(Initiative.all, :initiative, initiatives)
  end

  def country_options
    pluck_options(Country.all, :country, countries)
  end

  def sector_options
    @sector_options ||= Redesign::SectorTree.new.map do |parent, children|
      [
        FilterOption.new(parent.id, parent.name, :sector, sectors.include?(parent.id)),
        children.map { |sector|
          FilterOption.new(sector.id, sector.name, :sector, sectors.include?(sector.id))
        }
      ]
    end
  end

  def reporting_status_options
    @reporting_status_options ||= Organization.distinct.pluck(:cop_state).map do |state|
      FilterOption.new(state, state, :reporting_status, reporting_status.include?(state))
    end
  end

  def execute
    Organization.participants_only.search(keywords, options)
  end

  def keywords
    Riddle::Query.escape(super)
  end

  def per_page_options
    @per_page_options ||= [
      ["10 per page", 10],
      ["25 per page", 25],
      ["50 per page", 50]
    ]
  end

  def per_page_capped
    cap = per_page_options.map(&:last).max
    [per_page, cap].min
  end

  private

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

  def pluck_options(relation, type, selected)
    relation.pluck(:id, :name).map do |id, name|
      FilterOption.new(id, name, type, selected.include?(id))
    end
  end

  def order
    field = SORT_OPTIONS.fetch(sort_field, DEFAULT_ORDER)
    "#{field} #{sort_direction}"
  end

end
