class InitiativeContacts2 < SimpleReport

  def records
    Contact.find_by_sql("
    SELECT DISTINCT
    o.id AS organization_id,
    c.id AS contact_id,
    o.name AS organization_name,
    o.joined_on,
    i.added_on AS signed_mandate_on,
    t.name AS organization_type,
    o.cop_state,
    s.name AS sector_name,
    o.employees,
    o.is_ft_500,
    c.prefix,
    c.first_name,
    c.last_name,
    c.job_title,
    c.email,
    c.phone,
    c.fax,
    c.address,
    c.address_more,
    c.city,
    c.state,
    c.postal_code,
    country.name AS country_name,
    country.region AS region
    FROM
    contacts c
    LEFT JOIN organizations o ON c.organization_id = o.id
    LEFT JOIN countries country ON c.country_id = country.id
    LEFT JOIN organization_types t ON o.organization_type_id = t.id
    LEFT JOIN sectors s ON o.sector_id = s.id
    LEFT JOIN signings i ON i.organization_id = o.id
    LEFT JOIN `initiatives` init ON i.initiative_id = init.id
    LEFT JOIN contacts_roles cr ON cr.contact_id = c.id
    LEFT JOIN roles r ON r.id = cr.role_id
    WHERE
    i.initiative_id IN (2) AND
    r.id IN (12) AND
    o.cop_state != 'delisted'
    GROUP BY contact_id
    ORDER BY o.id")
  end

  def headers
    [
    'organization_id',
    'contact_id',
    'organization_name',
    'joined_on',
    'signed_mandate_on',
    'organization_type',
    'cop_state',
    'sector_name',
    'employees',
    'is_ft_500',
    'prefix',
    'first_name',
    'last_name',
    'job_title',
    'email',
    'phone',
    'fax',
    'address',
    'address_more',
    'city',
    'state',
    'postal_code',
    'country_name',
    'region_name'
    ]
  end

  def row(record)
  [
    record.organization_id,
    record.contact_id,
    record.organization_name,
    record.joined_on,
    record.signed_mandate_on,
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
    record.phone,
    record.fax,
    record.address,
    record.address_more,
    record.city,
    record.state,
    record.postal_code,
    record.country_name,
    Country::REGIONS[record.region.to_sym]
  ]
  end

end
