class AllCops < SimpleReport
  def records
    CommunicationOnProgress.all_cops
  end

  def render_output
    self.render_xls_in_batches
  end

  def headers
    [ 'participant_name',
      'country',
      'cop_web_link',
      'id',
      'organization_id',
      'title',
      'contact_info',
      'include_actions',
      'include_measurement',
      'use_indicators',
      'cop_score_id',
      'use_gri',
      'has_certification',
      'notable_program',
      'created_at',
      'updated_at',
      'published_on',
      'state',
      'include_continued_support_statement',
      'format',
      'references_human_rights',
      'references_labour',
      'references_environment',
      'references_anti_corruption',
      'meets_advanced_criteria',
      'additional_questions',
      'method_shared',
      'starts_on',
      'ends_on',
      'differentiation'
    ]
  end

  def row(record)
  [ record.organization.try(:name),
    record.organization.try(:country_name),
    'http://www.unglobalcompact.org/COPs/detail/' + record.id.to_s,
    record.id,
    record.organization_id,
    record.title,
    single_line(record.contact_info),
    record.include_actions ? 1:0,
    record.include_measurement ? 1:0,
    record.use_indicators ? 1:0,
    record.cop_score_id,
    record.use_gri ? 1:0,
    record.has_certification ? 1:0,
    record.notable_program ? 1:0,
    record.created_at.present? ? record.created_at.strftime('%Y-%m-%d %X') : 'invalid COP record',
    record.updated_at.present? ? record.updated_at.strftime('%Y-%m-%d %X') : 'invalid COP record',
    record.published_on,
    record.state,
    record.include_continued_support_statement ? 1:0,
    record.format,
    record.references_human_rights ? 1:0,
    record.references_labour ? 1:0,
    record.references_environment ? 1:0,
    record.references_anti_corruption ? 1:0,
    record.meets_advanced_criteria ? 1:0,
    record.additional_questions ? 1:0,
    record.method_shared,
    record.starts_on,
    record.ends_on,
    record.created_at.present? ? record.differentiation : 'invalid COP record'
  ]
  end

  private

  def single_line(contact_info)
    contact_info.gsub(/\r\n?/, ' ') if contact_info
  end

end
