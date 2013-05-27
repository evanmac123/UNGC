class ContactsExcelMacro < SimpleReport

  def records
    cop_states = [ Organization::COP_STATE_ACTIVE,
                   Organization::COP_STATE_NONCOMMUNICATING,
                   Organization::COP_STATE_DELISTED ]
    Contact.for_mail_merge(cop_states)
  end

  def render_output
    self.render_xls_in_batches
  end

  def headers
    [ 'Joined on',
      'Participant Name',
      'Participant Country',
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
      'Organization Type',
      'Sector',
      'Role',
      'Phone',
      'FT500',
      'COP Status',
      'Fax',
      'Username',
      'Password',
      'Number of Employees'
    ]
  end

  def row(record)
  [ record.joined_on,
    record.organization_name,
    record.organization_country,
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
    record.organization_type_name,
    record.sector_name,
    record.role_name,
    record.phone,
    record.is_ft_500,
    record.cop_state,
    record.fax,
    record.username,
    record.plaintext_password,
    record.employees
  ]
  end

end
