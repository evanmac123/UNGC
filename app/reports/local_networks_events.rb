class LocalNetworksEvents < SimpleReport

  def records
    LocalNetworkEvent.all(:include => [ :local_network, { :local_network => :countries } ])
  end

  def headers
    [ 'Local Network',
      'Event Title',
      'Description',
      'Date of Event',
      'Type of Event',
      'Total Number of Participants',
      'Percentage of Global Compact Participants',
      'Companies',
      'SMEs',
      'Business Associations',
      'Labour',
      'UN Agencies',
      'Civil Society',
      'Foundations',
      'Academic',
      'Government',
      'Media',
      'Event created',
      'Event updated',
      'Country',
      'Region'
    ]
  end

  def row(record)
  [ record.local_network.try(:name),
    record.title,
    record.description.present? ? record.description.gsub(/\r\n?/, ' ') : nil,
    record.date,
    record.type_name,
    record.num_participants,
    record.gc_participant_percentage,
    record.stakeholder_company? ? 1:0,
    record.stakeholder_sme? ? 1:0,
    record.stakeholder_business_association? ? 1:0,
    record.stakeholder_labour? ? 1:0,
    record.stakeholder_un_agency? ? 1:0,
    record.stakeholder_ngo? ? 1:0,
    record.stakeholder_foundation? ? 1:0,
    record.stakeholder_academic? ? 1:0,
    record.stakeholder_government? ? 1:0,
    record.stakeholder_media? ? 1:0,
    record.created_at.strftime('%Y-%m-%d'),
    record.updated_at.strftime('%Y-%m-%d'),
    record.local_network.try(:country_name),
    record.local_network.try(:region_name)
  ]
  end

end
