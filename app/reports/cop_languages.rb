class CopLanguages < SimpleReport

  def records
    CopFile.all_files
  end

  # participant_name
  # organization_id
  # country
  # Joined on
  # Organization Type
  # COP Status
  # differentiation
  # cop_id
  # created_at
  # updated_at
  # language

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
      record.communication_on_progress.differentiation_level,
      record.communication_on_progress.id,
      record.created_at.strftime('%Y-%m-%d %X'),
      record.updated_at.strftime('%Y-%m-%d %X'),
      record.language_name
    ]
  end

end
