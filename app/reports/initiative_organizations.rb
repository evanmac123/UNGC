class InitiativeOrganizations < SimpleReport

  InitiativeRecord = Struct.new(:signing, :organization, :initiative, :contribution)

  def records
    join_tables = [:organization_type, :sector, :country]

    signings = if @options[:initiatives]
      Signing.for_initiative_ids(@options[:initiatives]).joins(:organization => [join_tables] )
    else
      Signing.for_initiative_ids(Initiative.map(&:id)).joins(:organization => [join_tables] )
    end

    organizations = signings.map {|s| s.organization}
    contributions = ContributionStatusQuery.for_organizations(organizations)
    signings.map {|s| InitiativeRecord.new(
      s,
      s.organization,
      s.initiative,
      contributions[s.organization_id]
    )}
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
      'Country',
      'Region',
      'Revenue',
      'Last Contribution Year',
      'COP Status',
      'COP Differentiation'

    ]
  end

  def row(record)
  [
    record.organization.id,
    record.organization.name,
    record.organization.participant ? 1:0,
    record.organization.joined_on,
    record.initiative.name,
    record.signing.added_on,
    record.organization.organization_type_name,
    record.organization.employees,
    record.organization.is_ft_500 ? 1:0,
    record.organization.sector_name,
    record.organization.country_name,
    record.organization.region_name,
    record.organization.revenue_description,
    record.contribution.latest_contributed_year,
    record.organization.cop_state.titleize,
    record.organization.differentiation_level
  ]
  end

end
