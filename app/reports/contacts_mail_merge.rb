class ContactsMailMerge < SimpleReport

  def records
    cop_states = [ Organization::COP_STATE_ACTIVE, Organization::COP_STATE_NONCOMMUNICATING ]
    ContactsForMailMerge.new(cop_states)
  end

  def render_output
    self.render_xls_in_batches
  end

  def headers
    [ 'Participant ID',
      'Contact ID',
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
      'Region',
      'Phone',
      'Fax',
      'Role',
      'Username',
      'Welcome Package'
    ]
  end

  def row(record)
  [ record.organization_id,
    record.id,
    record.organization_name(
      local_network_name: record.network_name,
      organization_name: record.org_name
    ),
    record.organization_country,
    record.joined_on,
    record.organization_type_name,
    record.cop_state,
    record.sector_name,
    record.employees,
    record.is_ft_500,
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
    record.country_name_for_mail_merge,
    Country::REGIONS[record.region.to_sym],
    record.phone,
    record.fax,
    record.role_name,
    record.username,
    record.welcome_package
  ]
  end

end
