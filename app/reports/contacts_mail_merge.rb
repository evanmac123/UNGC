class ContactsMailMerge < SimpleReport

  def records    
    Contact.all( :include => [ { :organization => [:sector, :organization_type] }, :roles, :country ],
                 :conditions => ["organizations.cop_state in ('active','noncommunicating')
                                  and contacts_roles.role_id in (2,3)"],
                 :order => 'organization_id'
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
      # 'CEO',
      # 'Contact Point',
      'Username',
      'Password'
    ] 
  end

  def row(record)
  [ record.organization.id,
    record.id,
    record.organization.name,
    record.organization.joined_on,
    record.organization.organization_type.try(:name),
    record.organization.cop_state,
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
    record.country.name,
    record.country.region,
    record.phone,
    record.fax,
    # record.is?(Role.ceo),
    # record.is?(Role.contact_point),
    record.login,
    record.password
  ]
  end
  
end