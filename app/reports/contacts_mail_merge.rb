class ContactsMailMerge < SimpleReport

  def records
      Contact.find_by_sql("SELECT
      o.id as organization_id,
      c.id as contact_id,
      o.name as organization_name,
      org_country.name AS organization_country,
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
      CASE country.region
        WHEN 'africa'      THEN 'Africa'
        WHEN 'americas'    THEN 'Americas'
        WHEN 'asia'        THEN 'Asia'
        WHEN 'australasia' THEN 'Australasia'
        WHEN 'europe'      THEN 'Europe'
        WHEN 'mena'        THEN 'MENA'
      END AS region_name,
      r.name as role_name,
      c.phone,
      c.fax,
      c.login,
      c.password
      FROM
      contacts c
      JOIN organizations o ON c.organization_id = o.id
      JOIN countries country ON c.country_id = country.id
      JOIN countries org_country ON o.country_id = org_country.id
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
      'Password'
    ] 
  end

  def row(record)
  [ record.organization_id,
    record.contact_id,
    record.organization_name,
    record.organization_country,
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