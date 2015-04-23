class ParticipantSearch::Form
  include ActiveModel::Model

  attr_accessor \
    :organization_type,
    :initiative,
    :geography

  def organization_type_options
    pluck_options(OrganizationType.all)
  end

  def initiative_options
    pluck_options(Initiative.all)
  end

  def geography_options
    pluck_options(Country.all)
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

  def execute
    Organization.search(keywords, options)
  end

  private

  def keywords
    ''
  end

  def options
    options = {}

    options[:organization_type_id] = organization_type if organization_type.present?
    # options[:initiative_id] = initiative if initiative.present?
    options[:country_id] = geography if geography.present?

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

  def pluck_options(relation)
    relation.pluck(:id, :name).map do |id, name|
      Filter.new(id, name, true)
    end
  end

end
