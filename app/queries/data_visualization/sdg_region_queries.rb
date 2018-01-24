class DataVisualization::SdgRegionQueries
  attr :data

  def initialize(params)
    @region = params
  end

  def base_query
    CopAttribute
      .unscope(:order)
      .where("cop_answers.value": true)
      .where("cop_attributes.text like 'SDG%'")
  end

  def sdg_region_count
    base_query
    .joins(cop_answers: [communication_on_progress: [organization: :country]])
    .where("countries.region": @region)
    .group("cop_attributes.id")
    .select("cop_attributes.text, count(cop_answers.id) as answer_count")
    .map do |attr|
      { sdg: attr.text, count: attr.answer_count, region: @region }
    end
  end

  def sdg_region_sector_count
    base_query
    .joins(cop_answers: { communication_on_progress: { organization: [ :country, :sector] } })
    .where("countries.region": @region)
    .where("sectors.name != ?", 'Not Applicable')
    .group("cop_attributes.id, sectors.name")
    .select("cop_attributes.text, count(cop_answers.id) as answer_count, sectors.name as sector_name")
    .flat_map do |attr|
      [ sdg: attr.text, count: attr.answer_count, sector: attr.sector_name, region: @region ]
    end
  end

end
