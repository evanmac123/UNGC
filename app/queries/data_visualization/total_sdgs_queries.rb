class DataVisualization::TotalSdgsQueries

  def overall_sdg_breakdown
    CopAttribute.joins(cop_answers: [communication_on_progress: [:organization]])
    .where("cop_answers.value": true)
    .where("cop_attributes.text like 'SDG%'")
    .group("cop_attribute_id")
    .select("cop_attributes.*, count(cop_answers.id) as answer_count")
    .order("answer_count desc")
    .flat_map do |attr|
      [ sdg: attr.text, count: attr.answer_count ]
    end
  end

  def overall_sdg_sector_count
    CopAttribute.joins(cop_answers: { communication_on_progress: { organization: [:sector] } })
    .where("cop_answers.value": true)
    .where("cop_attributes.text like 'SDG%'")
    .group("sectors.name, cop_attribute_id")
    .where("sectors.name != ?", 'Not Applicable')
    .select("cop_attributes.*, count(cop_answers.id) as answer_count, sectors.name as sector_name")
    .flat_map do |attr|
      [ sdg: attr.text, count: attr.answer_count, sector: attr.sector_name ]
    end
  end

  def overall_sme_sdg_breakdown
    CopAttribute.joins(cop_answers: { communication_on_progress: { organization: [:organization_type] } })
    .where("cop_answers.value": true)
    .where("cop_attributes.text like 'SDG%'")
    .group("organization_types.name, cop_attribute_id")
    .where("organization_types.name = ?", 'SME')
    .select("cop_attributes.*, count(cop_answers.id) as answer_count, organization_types.name as organization_type_name")
    .flat_map do |attr|
      [ sdg: attr.text, count: attr.answer_count, organization_type: attr.organization_type_name ]
    end

  end

  def overall_company_sdg_breakdown
    CopAttribute.joins(cop_answers: { communication_on_progress: { organization: [:organization_type] } })
    .where("cop_answers.value": true)
    .where("cop_attributes.text like 'SDG%'")
    .group("organization_types.name, cop_attribute_id")
    .where("organization_types.name = ?", 'Company')
    .select("cop_attributes.*, count(cop_answers.id) as answer_count, organization_types.name as organization_type_name")
    .flat_map do |attr|
      [ sdg: attr.text, count: attr.answer_count, organization_type: attr.organization_type_name ]
    end

  end

end
