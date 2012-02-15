class CopsWithDifferentiation < SimpleReport

  def records
    CommunicationOnProgress.for_year(2011).all(:include => [ :organization,
                                                           { :organization => :country,
                                                             :organization => :organization_type } ])
  end

  def headers
    [ 'Participant Name',
      'Organization Type',
      'Country',
      'COP ID',
      'Organization ID',
      'Title',
      'Created at',
      'Updated at',
      'Format',
      'Includes Continued Support Statement',
      'Includes Measurement',
      'References Human Rights',
      'References Labour',
      'References Environment',
      'References Anti-Corruption',
      'Meets Advanced Criteria',
      'Completed Advanced COP',
      'Coverage starts on',
      'Coverage ends on',
      'Differentiation Level'
    ]
  end

  def row(record)
    [ record.organization.name,
      record.organization.organization_type_name,
      record.organization.country_name,
      record.id,
      record.organization_id,
      record.title,
      record.created_at.present? ? record.created_at.strftime('%Y-%m-%d %X') : 'invalid COP record',
      record.updated_at.present? ? record.updated_at.strftime('%Y-%m-%d %X') : 'invalid COP record',
      record.format,
      record.include_continued_support_statement ? 1:0,
      record.include_measurement ? 1:0,
      record.references_human_rights ? 1:0,
      record.references_labour ? 1:0,
      record.references_environment ? 1:0,
      record.references_anti_corruption ? 1:0,
      record.meets_advanced_criteria ? 1:0,
      record.additional_questions ? 1:0,
      record.starts_on,
      record.ends_on,
      record.created_at.present? ? record.differentiation_level : 'invalid COP record'
    ]
  end

end
