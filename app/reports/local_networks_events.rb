class LocalNetworksEvents < SimpleReport

  def records
    LocalNetworkEvent.all.
      select('local_network_events.local_network_id,
        local_network_events.title,
        local_network_events.description,
        local_network_events.date,
        local_network_events.event_type,
        local_network_events.num_participants,
        local_network_events.gc_participant_percentage,
        local_network_events.stakeholder_company,
        local_network_events.stakeholder_sme,
        local_network_events.stakeholder_business_association,
        local_network_events.stakeholder_labour,
        local_network_events.stakeholder_un_agency,
        local_network_events.stakeholder_ngo,
        local_network_events.stakeholder_foundation,
        local_network_events.stakeholder_academic,
        local_network_events.stakeholder_government,
        local_network_events.stakeholder_media,
        local_network_events.stakeholder_others,
        local_network_events.created_at,
        local_network_events.updated_at,
        local_network_events_principles.*').
      joins(:principles).
      includes(:local_network, { local_network: :countries }, :principles).
      order('local_network_events.local_network_id, local_network_events.date DESC')
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
