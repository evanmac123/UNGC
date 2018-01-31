class DataVisualization::SdgCountryQueries
  attr_reader :data

  def initialize(country_id = nil)
    @country_name = Country.find(country_id).name

    @country_id = country_id

    @data = CopAnswer
        .joins(communication_on_progress: [organization: [:country]], cop_attribute: [:cop_question])
        .includes(communication_on_progress: [{ organization: [:sector, :country, :organization_type] }], cop_attribute: [:cop_question ])
        .where("value = :val or cop_answers.text > ''", val: true)
        .where(cop_questions: { grouping: :sdgs })
        .order(:cop_id, "cop_questions.id")
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

  def base_query
    CopAttribute
        .joins(cop_answers: [communication_on_progress: [organization: [:country, :sector]]])
        .where(organizations: { country_id: @country_id })
        .sdg_question_with_answer
  end

  def country_sdg_count
    base_query
        .group("cop_attributes.id")
        .select("cop_attributes.text, count(cop_answers.id) as answer_count")
  end

  def sdg_country_sector_count
    base_query
        .merge(Sector.applicable)
        .group("sectors.name, cop_attributes.id")
        .select("cop_attributes.text, count(cop_answers.id) as answer_count, sectors.name as sector_name")
  end

end
