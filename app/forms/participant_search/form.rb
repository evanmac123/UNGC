class ParticipantSearch::Form
  include ActiveModel::Model

  attr_accessor \
    :organization_types,
    :initiatives,
    :countries,
    :sectors,
    :reporting_status

  def initialize(*args)
    super(*args)
    @sectors ||= []
  end

  def organization_type_options
    pluck_options(OrganizationType.all, self.organization_types)
  end

  def initiative_options
    pluck_options(Initiative.all, self.initiatives)
  end

  def country_options
    pluck_options(Country.all, self.countries)
  end

  def sector_options
    @sector_options ||= Redesign::SectorTree.new.map do |parent, children|
      [
        Filter.new(parent.id, parent.name, sectors.include?(parent.id.to_s)),
        children.map { |sector|
          Filter.new(sector.id, sector.name, sectors.include?(sector.id.to_s))
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

  def page
    @page || 1
  end

  def per_page
    @per_page || 12
  end

  def order
    @order
  end

  private

  def keywords
    ''
  end

  def options
    options = {}

    options[:organization_type_id] = organization_types if organization_types.present?
    options[:initiative_ids] = initiatives if initiatives.present?
    options[:country_id] = countries if countries.present?
    options[:sector_id] = sectors if sectors.present?

    if reporting_status.present?
      options[:cop_state] = reporting_status.map {|state| Zlib.crc32(state)}
    end

    {
      page: page || 1,
      per_page: per_page || 12,
      order: order,
      star: true,
      with: options,
      indices: ['participant_search_core'],
      sql: {
        include: [
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
      Filter.new(id, name, Array(selected).include?(id.to_s))
    end
  end

end
