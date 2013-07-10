class CopRequiredElements < SimpleReport

  def records
    CommunicationOnProgress.new_policy(:include => [ :organization, { :organization => :country } ])
  end

  def render_output
    self.render_xls_in_batches
  end

  def headers
    [ 'participant_name',
      'country',
      'organization_id',
      'cop_web_link',
      'id',
      'title',
      'format',
      'include_continued_support_statement',
      'references_human_rights',
      'references_labour',
      'references_environment',
      'references_anti_corruption',
      'include_measurement',
      'additional_questions',
      'meets_advanced_criteria',
      'method_shared',
      'starts_on',
      'ends_on',
      'differentiation',
      'created_at',
      'updated_at'
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
      record.created_at.present? ? record.differentiation : 'invalid COP record',
      record.created_at.present? ? record.created_at.strftime('%Y-%m-%d %X') : 'invalid COP record',
      record.updated_at.present? ? record.updated_at.strftime('%Y-%m-%d %X') : 'invalid COP record'
    ]
  end

end
