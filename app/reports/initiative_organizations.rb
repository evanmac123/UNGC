class InitiativeOrganizations < SimpleReport

  def records
    join_tables = [:organization_type, :sector, :country]
    if @options[:initiatives]
      Signing.for_initiative_ids(@options[:initiatives]).joins(:organization => [join_tables] )
    else
      Signing.for_initiative_ids(Initiative.for_select.map(&:id)).joins(:organization => [join_tables] )
    end
  end
  
  def organization_count
    records.map(&:organization_id).uniq.count
  end
  
  def initiative_count
    records.map(&:initiative_id).uniq.count
  end
  
  def headers
    [
      'Organization ID',
      'Organization name',
      'Participant',
      'Joined Global Compact on',
      'Initiative name',
      'Signed initiative on',
      'Organization Type',
      'Employees',
      'FT500',
      'Sector',
      'Country'
    ]
  end

  def row(record)
  [
    record.organization.id,
    record.organization.name,
    record.organization.participant ? 1:0,
    record.organization.joined_on,
    record.initiative.name,
    record.added_on,
    record.organization.organization_type_name,
    record.organization.employees,
    record.organization.is_ft_500 ? 1:0,
    record.organization.sector_name,
    record.organization.country_name
  ]
  end

end