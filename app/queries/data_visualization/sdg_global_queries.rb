class DataVisualization::SdgGlobalQueries

  def base_query
    CopAttribute
        .where("cop_answers.value": true)
        .where("cop_attributes.text like 'SDG%'")
  end

  def overall_sdg_breakdown
    base_query
        .joins(:cop_answers)
        .group("cop_attribute_id, cop_attributes.text")
        .reorder("answer_count desc")
        .select("cop_attributes.text, count(cop_answers.id) as answer_count")
        .flat_map { |attr| [ sdg: attr.text, count: attr.answer_count ] }
  end

  def overall_sdg_sector_count
    base_query
        .joins(cop_answers: { communication_on_progress: { organization: [:sector] } })
        .where("sectors.name != :v", v: 'Not Applicable')
        .group("cop_attribute_id, cop_attributes.text, sectors.name")
        .unscope(:order)
        .select("cop_attributes.text, count(cop_answers.id) as answer_count, sectors.name as sector_name")
        .flat_map { |attr| [ sdg: attr.text, count: attr.answer_count, sector: attr.sector_name ] }
  end

  def overall_org_type_sdg_breakdown(org_type)
    base_query
        .joins(cop_answers: { communication_on_progress: { organization: [:organization_type] } })
        .group("organization_types.name, cop_attribute_id, copy_attributes.text")
        .where(organization_types: { name: org_type })
        .select("cop_attributes.text, count(cop_answers.id) as answer_count, organization_types.name as organization_type_name")
        .flat_map { |attr| [ sdg: attr.text, count: attr.answer_count, organization_type: attr.organization_type_name ] }
  end

  def overall_sme_sdg_breakdown
    overall_org_type_sdg_breakdown('SME')
  end

  def overall_company_sdg_breakdown
    overall_org_type_sdg_breakdown('Company')
  end

end
