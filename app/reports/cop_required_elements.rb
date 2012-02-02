include ActionController::UrlWriter
class CopRequiredElements < SimpleReport

  def records
    CommunicationOnProgress.new_policy(:include => [ :organization, { :organization => :country } ])
  end

  def headers
    [ 'Participant Name',
      'Participant Country',
      'Participant ID',
      'Web link to COP',
      'COP ID',
      'Title',
      'Format',
      'Includes CEO Statement of Continued Support',
      'References Human Rights',
      'References Labour',
      'References Environment',
      'References Anti-Corruption',
      'Includes Measurement of Outcomes',
      'Advanced Questionnaire',
      'Meets 24 Advanced Criteria',
      'Method of Sharing COP',
      'Coverage starts on',
      'Coverage ends on',
      'Differentiation Level',
      'Created at',
      'Updated at'
    ]
  end

  def row(record)
    [ record.organization.try(:name),
      record.organization.try(:country_name),
      record.organization_id,
      cop_detail_url(record.id, :host => 'www.unglobalcompact.org'),
      record.id,
      record.title,
      record.format,
      record.include_continued_support_statement ? 1:0,
      record.references_human_rights ? 1:0,
      record.references_labour ? 1:0,
      record.references_environment ? 1:0,
      record.references_anti_corruption ? 1:0,
      record.include_measurement ? 1:0,
      record.additional_questions ? 1:0,
      record.meets_advanced_criteria ? 1:0,
      record.method_shared,
      record.starts_on,
      record.ends_on,
      record.created_at.present? ? record.differentiation_level : 'invalid COP record',
      record.created_at.present? ? record.created_at.strftime('%Y-%m-%d %X') : 'invalid COP record',
      record.updated_at.present? ? record.updated_at.strftime('%Y-%m-%d %X') : 'invalid COP record'
    ]
  end

end
