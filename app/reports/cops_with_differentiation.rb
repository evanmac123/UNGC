class CopsWithDifferentiation < SimpleReport

  def records
    CommunicationOnProgress.since_year(2011)
  end

  def render_output
    self.render_xls_in_batches
  end

  def headers
    [ 'participant_name',
      'organization_type',
      'country',
      'id',
      'organization_id',
      'title',
      'created_at',
      'updated_at',
      'published_on',
      'format',
      'include_continued_support_statement',
      'include_measurement',
      'references_human_rights',
      'references_labour',
      'references_environment',
      'references_anti_corruption',
      'meets_advanced_criteria',
      'additional_questions',
      'starts_on',
      'ends_on',
      'differentiation'
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
      record.published_on,
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
      record.created_at.present? ? record.differentiation : 'invalid COP record'
    ]
  end

end
