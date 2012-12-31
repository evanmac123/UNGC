class LocalNetworkParticipantContacts < SimpleReport

  def records
    Contact.visible_to(@options[:user]).participants_only.for_local_network
  end

  def render_output
    self.render_xls
  end

  def headers
    [ 'Participant ID',
      'Participant Name',
      'Participant Country',
      'Joined on',
      'Organization Type',
      'COP Status',
      'Sector',
      'Number of Employees',
      'FT500',
      'Prefix',
      'First Name',
      'Last Name',
      'Job Title',
      'Email',
      'Address',
      'Address 2',
      'City',
      'State',
      'Postal Code',
      'Country',
      'Phone',
      'Fax',
      'Role',
      'Username',
      'Password'
    ]
  end

  def row(record)
    [ record.organization.id,
      record.organization_name,
      record.organization.country_name,
      record.organization.joined_on,
      record.organization.organization_type_name,
      record.organization.cop_state.titleize,
      record.organization.sector_name,
      record.organization.employees,
      record.organization.is_ft_500,
      record.prefix,
      record.first_name,
      record.last_name,
      record.job_title,
      record.email,
      record.address,
      record.address_more,
      record.city,
      record.state,
      record.postal_code,
      record.country_name,
      record.phone,
      record.fax,
      record.roles.first.name,
      record.username,
      record.password
    ]
  end

end
