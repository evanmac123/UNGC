class LocalNetworksAllContacts < SimpleReport
  def records
    Contact
        .for_roles(Role.network_roles_public)
        .joins(:local_network)
        .includes(:country)
        .where.not(local_networks: { state: :inactive })
  end

  def headers
    [ 'Contact ID',
      'Local Network ID',
      'Prefix',
      'First Name',
      'Last Name',
      'Full Name',
      'Job Title',
      'Email',
      'Phone',
      'Fax',
      'Address',
      'Address 2',
      'City',
      'State',
      'Postal Code',
      'Contact Country',
      'Network Executive Director',
      'Network Contact Person',
      'Network Board Chair',
      'Local Network Name',
      'Local Network Stage',
      'Country ISO Code',
      'Local Network Country',
      'Region'
    ]
  end

  def row(r)
    c = nil
    countries = r.try(:local_network).try(:countries)
    if countries
      c = countries.map(&:code).join(',')
    end
    [ r.try(:id),
      r.try(:local_network_id),
      r.try(:prefix),
      r.try(:first_name),
      r.try(:last_name),
      r.try(:name),
      r.try(:job_title),
      r.try(:email),
      r.try(:phone),
      r.try(:fax),
      r.try(:address),
      r.try(:address_more),
      r.try(:city),
      r.try(:state),
      r.try(:postal_code),
      r.try(:country).try(:name),
      r.is?(Role.network_executive_director) ? 1:0,
      r.is?(Role.network_focal_point) ? 1:0,
      r.is?(Role.network_board_chair) ? 1:0,
      r.try(:local_network).try(:name) || 'Unknown',
      r.try(:local_network).try(:state).try(:humanize) || 'None',
      c,
      r.try(:local_network).try(:country).try(:name),
      r.try(:local_network).try(:region_name)
    ]
  end
end
