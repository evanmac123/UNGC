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

  def organization_type_options
    pluck_options(OrganizationType.all, organization_types)
  end

  def initiative_options
    pluck_options(Initiative.all, initiatives)
  end

  def country_options
    pluck_options(Country.all, countries)
  end

  def sector_options
    @sector_options ||= Redesign::SectorTree.new.map do |parent, children|
      [
        Filter.new(parent.id, parent.name, sectors.include?(parent.id)),
        children.map { |sector|
          Filter.new(sector.id, sector.name, sectors.include?(sector.id))
        }
      ]
    end
  end

  def reporting_status_options
    @reporting_status_options ||= Organization.distinct.pluck(:cop_state).map do |state|
      Filter.new(state, state, Array(reporting_status).include?(state))
    end
  end

  def execute
    Organization.search(keywords, options)
  end

  private

  def keywords
    Riddle::Query.escape(super)
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

  Filter = Struct.new(:id, :name, :active)

  def pluck_options(relation, selected)
    relation.pluck(:id, :name).map do |id, name|
      Filter.new(id, name, selected.include?(id))
    end
  end

end
