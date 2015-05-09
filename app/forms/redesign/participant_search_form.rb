class Redesign::ParticipantSearchForm
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
  attribute :sort_field,          String,         default: 'joined_on_desc'

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
    Organization.search(keywords, options)
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

  def sort_options
    @sort_options ||= [
      ["Joined On", :joined_on_asc],
      ["Joined On Desc", :joined_on_desc],
      ["Name",          :name_asc],
      ["Name Desc",          :name_desc],
      ["Type",          :type_asc],
      ["Sector",   :sector_asc],
      ["Country",   :country_asc],
      ["Company Size",   :company_size_asc]
    ]
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

    order = case self.sort_field
    when 'name_asc'
      'name asc'
    when 'name_desc'
      'name desc'
    when 'joined_on_asc'
      'joined_on asc'
    # TODO make other sorting fields work
    when 'type_asc'
      'type asc'
    when 'sector_asc'
      'sector asc'
    when 'company_size_asc'
      'company_size asc'
    else
      'joined_on desc'
    end

    {
      page: page,
      per_page: per_page,
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

end
