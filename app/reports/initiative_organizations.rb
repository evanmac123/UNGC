class InitiativeOrganizations < SimpleReport

  def records
    if @options[:initiatives]
      Signing.for_initiative_ids(@options[:initiatives])
    else
      Signing.for_initiative_ids(Initiative.for_select.map(&:id))
    end
  end
  
  def headers
    [
    'organization_id',
    'organization_name',
    'initiative_name'
  ]
  end

  def row(record)
  [
    record.organization.id,
    record.organization.name,
    record.initiative.name
  ]
  end

end