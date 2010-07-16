class ContactsExcelMacro < SimpleReport

  def records
      Contact.find_by_sql("SELECT
            o.id AS organization_id,
            c.id AS contact_id,
            o.name AS organization_name,
            o.joined_on,
            t.name AS organization_type,
            o.cop_state,
            remove.description as removal_description,
            s.name AS sector_name,
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
            country.name AS country_name,
            country.region AS region_name,
            r.name AS role_name,
            c.phone,
            c.fax,
            c.login,
            c.password
            FROM
            contacts c
            JOIN organizations o ON c.organization_id = o.id
            JOIN countries country ON c.country_id = country.id
            JOIN organization_types t ON o.organization_type_id = t.id
            JOIN removal_reasons remove ON o.removal_reason_id = remove.id
            JOIN sectors s ON o.sector_id = s.id
            LEFT OUTER JOIN contacts_roles ON contacts_roles.contact_id = c.id
            RIGHT OUTER JOIN roles r ON r.id = contacts_roles.role_id
            WHERE o.cop_state IN ('active','noncommunicating','delisted') AND
            o.removal_reason_id NOT IN (2,3,5,6) AND
            o.participant = 1 AND
            t.name NOT IN ('Media Organization', 'GC Networks', 'Mailing List') AND
            contacts_roles.role_id IN (2,3)
            ORDER BY o.id",
      )
  end
    
  def headers
    [ 'Joined on',
      'Participant Name',
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
      'Reason for Delisting',
      'Fax',
      'Username',
      'Password',
      'Number of Employees'
    ] 
  end

  def row(record)
  [ record.joined_on,
    record.organization_name,
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
    record.organization_type,
    record.sector_name,
    record.role_name,
    record.phone,
    record.is_ft_500,
    record.cop_state,
    record.removal_description,
    record.fax,
    record.login,
    record.password,
    record.employees
  ]
  end
  
end