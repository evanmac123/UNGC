class LocalNetworksContacts < SimpleReport
  def records
    Contact.network_roles.all(:include => :local_network,
                                 :order => 'local_networks.name')
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
      'Country',
      'Network Focal Point',
      'Network Representative',
      'Network Report Recipient',
      'Local Network Name',
      'Local Network Stage',
      'Country ISO Code',
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
      r.is?(Role.network_focal_point) ? 1:0,
      r.is?(Role.network_representative) ? 1:0,
      r.is?(Role.network_report_recipient) ? 1:0,
      r.try(:local_network).try(:name) || 'Unknown',
      r.try(:local_network).try(:state).try(:humanize) || 'None',
      r.try(:local_network).try(:countries).map(&:code).join(','),
      r.try(:local_network).try(:countries).try(:first).try(:region)
    ]
  end
end