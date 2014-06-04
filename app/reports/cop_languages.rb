class CopLanguages < SimpleReport

  def records
    CopFile.all_files
  end

  def render_output
    self.render_xls_in_batches
  end

  def headers
    [ 'participant_name',
      'organization_id',
      'country',
      'joined_on',
      'organization_type',
      'cop_status',
      'differentiation',
      'cop_id',
      'created_at',
      'updated_at',
      'published_on',
      'language'
      ]
  end

  def row(record)
    [ record.communication_on_progress.try(:organization_name),
      record.communication_on_progress.organization_id,
      record.communication_on_progress.country_name,
      record.communication_on_progress.organization_joined_on,
      record.communication_on_progress.organization_type,
      record.communication_on_progress.organization_cop_state,
      record.communication_on_progress.differentiation,
      record.communication_on_progress.id,
      record.created_at.strftime('%Y-%m-%d %X'),
      record.updated_at.strftime('%Y-%m-%d %X'),
      record.published_on,
      record.language_name
    ]
  end

end
