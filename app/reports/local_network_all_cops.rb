class LocalNetworkAllCops < SimpleReport

  def records
    user = Contact.find(@options[:contact_id])
    CommunicationOnProgress.visible_to(user).all_cops.approved
  end

  def render_output
    self.render_xls
  end

  def headers
    [ 'participant_name',
      'cop_status',
      'organization_type',
      'country',
      'title',
      'published_on',
      'format',
      'include_continued_support_statement',
      'include_measurement',
      'references_human_rights',
      'references_labour',
      'references_environment',
      'references_anti_corruption',
      'meets_advanced_criteria',
      'starts_on',
      'ends_on',
      'differentiation'
    ]
  end

  def row(record)
    [ record.organization.try(:name),
      record.organization.try(:cop_state),
      record.organization.organization_type_name,
      record.organization.country_name,
      record.title,
      record.published_on,
      record.format,
      record.include_continued_support_statement ? 1:0,
      record.include_measurement ? 1:0,
      record.references_human_rights ? 1:0,
      record.references_labour ? 1:0,
      record.references_environment ? 1:0,
      record.references_anti_corruption ? 1:0,
      record.meets_advanced_criteria ? 1:0,
      record.starts_on,
      record.ends_on,
      record.created_at.present? ? record.differentiation : 'invalid COP record'
    ]
  end

end
