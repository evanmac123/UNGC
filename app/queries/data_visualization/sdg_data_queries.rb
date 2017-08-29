class DataVisualization::SdgDataQueries
  attr_reader :data

  def initialize(country_id = nil)
    @country_name = Country.find(country_id).name

    @country_id = country_id

    @data = CopAnswer.joins(communication_on_progress: [organization: [:country]],
                    cop_attribute: [:cop_question]).
    includes(communication_on_progress: [{ organization: [:sector, :country, :organization_type] }],
             cop_attribute: [:cop_question ]).
    where("value = 1 or cop_answers.text <> ''").
    where("grouping = 'sdgs'").
    order(:cop_id, "cop_questions.id")
  end

  def sdg_cop_attributes(country_id)
    country_cop_answers = data.where("organizations.country_id": country_id)
    country_cop_answers.pluck(:cop_attribute_id)
  end

  def sdg_text_answers
    attribute_ids = sdg_cop_attributes(country_id)
    sdg_text_array = []
    attribute_ids.each do |id|
      sdg_text_array << CopAttribute.find(id).text
    end
    sdg_text_array
  end

  def country_sdg_count_with_id(country_id)
    CopAttribute.joins(cop_answers: [communication_on_progress: [organization: :country]])
    .where("countries.id": country_id)
    .where("cop_answers.value": true)
    .where("cop_attributes.text like 'SDG%'")
    .group("cop_attribute_id")
    .select("cop_attributes.*, count(cop_answers.id) as answer_count")
    .map do |attr|
      [attr.id, attr.text, attr.answer_count]
    end
  end

  def country_sdg_count
    CopAttribute.joins(cop_answers: [communication_on_progress: [organization: :country]])
    .where("countries.id": @country_id)
    .where("cop_answers.value": true)
    .where("cop_attributes.text like 'SDG%'")
    .group("cop_attribute_id")
    .select("cop_attributes.*, count(cop_answers.id) as answer_count")
    .map do |attr|
      { sdg: attr.text, count: attr.answer_count, country: @country_name }
    end
  end

  def sdg_country_sector_count
    CopAttribute.joins(cop_answers: { communication_on_progress: { organization: [ :country, :sector] } })
    .where("countries.id": @country_id)
    .where("cop_answers.value": true)
    .where("cop_attributes.text like 'SDG%'")
    .group("sectors.name, cop_attribute_id")
    .where("sectors.name != ?", 'Not Applicable')
    .select("cop_attributes.*, count(cop_answers.id) as answer_count, sectors.name as sector_name")
    .flat_map do |attr|
      [ sdg: attr.text, count: attr.answer_count, sector: attr.sector_name, country: @country_name ]
    end
  end

end
