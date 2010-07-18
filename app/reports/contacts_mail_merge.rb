class ContactsMailMerge < SimpleReport

  def records
      Contact.find_by_sql("SELECT
      o.id as organization_id,
      c.id as contact_id,
      o.name as organization_name,
      o.joined_on,
      t.name as organization_type,
      o.cop_state,
      s.name as sector_name,
      o.employees,
      o.is_ft_500,
      c.prefix,
      c.first_name,
      c.last_name,
      c.job_title,
      c.email,
      c.address,
      c.address_more,
      c.city,
      c.state,
      c.postal_code,
      country.name as country_name,
      country.region as region_name,
      r.name as role_name,
      c.phone,
      c.fax,
      c.login,
      c.password
      FROM
      contacts c
      JOIN organizations o ON c.organization_id = o.id
      JOIN countries country ON c.country_id = country.id
      JOIN organization_types t ON o.organization_type_id = t.id
      JOIN sectors s ON o.sector_id = s.id
      LEFT OUTER JOIN contacts_roles ON contacts_roles.contact_id = c.id
      RIGHT OUTER JOIN roles r ON r.id = contacts_roles.role_id
      WHERE o.cop_state IN ('active','noncommunicating') AND
      o.participant = 1 AND
      t.name NOT IN ('Media Organization', 'GC Networks', 'Mailing List') AND
      contacts_roles.role_id IN (2,3)
      ORDER by o.id"
      )
  end
    
  def headers
    [ 'Participant ID',
      'Contact ID',
      'Participant Name',
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
      'Password'
    ] 
  end

  def row(record)
  [ record.organization_id,
    record.contact_id,
    record.organization_name,
    record.joined_on,
    record.organization_type,
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
    record.country_name,
    record.region_name,
    record.phone,
    record.fax,
    record.role_name,
    record.login,
    record.password
  ]
  end
  
end