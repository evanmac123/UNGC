class LocalNetworksContacts < SimpleReport
  def records
    Contact.roles_for_network_report.includes(:local_network).order('local_networks.name')
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
      'Network Board Chair',
      'Network Contact Person',
      'Network Report Recipient',
      'General Contact',
      'Username',
      'Local Network Name',
      'Local Network Stage',
      'Country ISO Code',
      'Local Network Country',
      'Region'
    ]
  end

  def row(r)
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
      r.is?(Role.network_board_chair) ? 1:0,
      r.is?(Role.network_focal_point) ? 1:0,
      r.is?(Role.network_report_recipient) ? 1:0,
      r.is?(Role.general_contact) ? 1:0,
      r.try(:username),
      r.try(:local_network).try(:name) || 'Unknown',
      r.try(:local_network).try(:state).try(:humanize) || 'None',
      r.try(:local_network).try(:countries).map(&:code).join(','),
      r.try(:local_network).try(:country).try(:name),
      r.try(:local_network).region_name
    ]
  end
end
