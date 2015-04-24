class ParticipantSearch::Form
  include ActiveModel::Model

  attr_accessor \
    :organization_types,
    :initiatives,
    :countries

  def organization_type_options
    pluck_options(OrganizationType.all, self.organization_types)
  end

  def initiative_options
    pluck_options(Initiative.all, self.initiatives)
  end

  def country_options
    pluck_options(Country.all, self.countries)
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
    # options[:initiative_id] = initiative if initiative.present?
    options[:country_id] = countries if countries.present?

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
      Filter.new(id, name, Array(selected).include?(id))
    end
  end

end
