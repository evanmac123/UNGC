class LocalNetworkParticipantContacts < SimpleReport

  def records
    Contact.for_local_network(sql_for_organization_scope)
  end

  def render_output
    self.render_xls_in_batches
  end

  def headers
     [ 'Joined on',
       'Participant Name',
       'Participant Country',
       'Role',
       'Prefix',
       'First Name',
       'Last Name',
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
       'Organization Type',
       'Sector',
       'FT500',
       'COP Status',
       'Number of Employees',
       'Username',
       'Password'
     ]
  end

  def row(record)
    [ record.organization.joined_on,
      record.organization_name,
      record.organization.country_name,
      record.roles.first.name,
      record.prefix,
      record.first_name,
      record.last_name,
      record.job_title,
      record.email,
      record.phone,
      record.fax,
      record.address,
      record.address_more,
      record.city,
      record.state,
      record.postal_code,
      record.country_name,
      record.organization.organization_type_name,
      record.organization.sector_name,
      record.organization.is_ft_500,
      record.organization.cop_state,
      record.organization.employees,
      record.login,
      record.password
    ]
  end

end
