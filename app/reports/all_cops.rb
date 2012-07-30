include ActionController::UrlWriter
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
      'identifier',
      'organization_id',
      'title',
      'related_document',
      'email',
      'job_title',
      'url1',
      'url2',
      'url3',
      'contact_name',
      'include_ceo_letter',
      'include_actions',
      'include_measurement',
      'use_indicators',
      'cop_score_id',
      'use_gri',
      'has_certification',
      'notable_program',
      'created_at',
      'updated_at',
      'state',
      'include_continued_support_statement',
      'format',
      'references_human_rights',
      'references_labour',
      'references_environment',
      'references_anti_corruption',
      'replied_to',
      'reviewer_id',
      'support_statement_signee',
      'parent_company_cop',
      'parent_cop_cover_subsidiary',
      'meets_advanced_criteria',
      'additional_questions',
      'support_statement_explain_benefits',
      'missing_principle_explained',
      'is_shared_with_stakeholders',
      'method_shared',
      'starts_on',
      'ends_on',
      'differentiation'
    ]
  end

  def row(record)
  [ record.organization.try(:name),
    record.organization.try(:country_name),
    cop_detail_url(record.id, :host => 'www.unglobalcompact.org'),
    record.id,
    record.identifier,
    record.organization_id,
    record.title,
    record.related_document,
    record.email,
    record.job_title,
    record.url1,
    record.url2,
    record.url3,
    record.contact_name.present? ? record.contact_name.gsub(/\r\n?/, ' ') : nil,
    record.include_ceo_letter ? 1:0,
    record.include_actions ? 1:0,
    record.include_measurement ? 1:0,
    record.use_indicators ? 1:0,
    record.cop_score_id,
    record.use_gri ? 1:0,
    record.has_certification ? 1:0,
    record.notable_program ? 1:0,
    record.created_at.present? ? record.created_at.strftime('%Y-%m-%d %X') : 'invalid COP record',
    record.updated_at.present? ? record.updated_at.strftime('%Y-%m-%d %X') : 'invalid COP record',
    record.state,
    record.include_continued_support_statement ? 1:0,
    record.format,
    record.references_human_rights ? 1:0,
    record.references_labour ? 1:0,
    record.references_environment ? 1:0,
    record.references_anti_corruption ? 1:0,
    record.replied_to ? 1:0,
    record.reviewer_id,
    record.support_statement_signee,
    record.parent_company_cop ? 1:0,
    record.parent_cop_cover_subsidiary ? 1:0,
    record.meets_advanced_criteria ? 1:0,
    record.additional_questions ? 1:0,
    record.support_statement_explain_benefits ? 1:0,
    record.missing_principle_explained ? 1:0,
    record.is_shared_with_stakeholders ? 1:0,
    record.method_shared,
    record.starts_on,
    record.ends_on,
    record.created_at.present? ? record.differentiation_level : 'invalid COP record'
  ]
  end

end
