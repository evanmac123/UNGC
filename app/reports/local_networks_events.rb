class LocalNetworksEvents < SimpleReport

  def records
    LocalNetworkEvent.all(:select => 'local_network_id, title, description, date, event_type, num_participants, gc_participant_percentage, stakeholder_company, stakeholder_sme, stakeholder_business_association, stakeholder_labour, stakeholder_un_agency, stakeholder_ngo, stakeholder_foundation, stakeholder_academic, stakeholder_government, stakeholder_media, stakeholder_others, created_at, updated_at, local_network_events_principles.*',
                          :include => [ :local_network, { :local_network => :countries }, :principles, ],
                          :order =>  'local_network_events.local_network_id, local_network_events.date DESC'
                          )
  end

  def headers
    [ 'Local Network',
      'Event Title',
      'Description',
      'Date of Event',
      'Type of Event',
      'Total Number of Participants',
      'Percentage of Global Compact Participants',
      'Companies present?',
      'SMEs present?',
      'Business Associations present?',
      'Labour present?',
      'UN Agencies present?',
      'Civil Society present?',
      'Foundations present?',
      'Academic present?',
      'Government present?',
      'Media present?',
      'Human Rights Covered?',
      'Labour Covered?',
      'Environment Covered?',
      'Anti-Corruption Covered?',
      'Business and Peace Covered?',
      'Financial Markets Covered?',
      'Business for Development Covered?',
      'UN / Business Partnerships Covered?',
      'Supply Chain Sustainability Covered?',
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
    record.covers?(:human_rights) ? 1:0,
    record.covers?(:labour) ? 1:0,
    record.covers?(:environment) ? 1:0,
    record.covers?(:anti_corruption) ? 1:0,
    record.covers?(:business_peace) ? 1:0,
    record.covers?(:financial_markets) ? 1:0,
    record.covers?(:business_development) ? 1:0,
    record.covers?(:un_business) ? 1:0,
    record.covers?(:supply_chain) ? 1:0,
    record.created_at.strftime('%Y-%m-%d'),
    record.updated_at.strftime('%Y-%m-%d'),
    record.local_network.try(:country_name),
    record.local_network.try(:region_name)
  ]
  end

end
