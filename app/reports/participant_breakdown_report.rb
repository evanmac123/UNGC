class ParticipantBreakdownReport < SimpleReport
  def records
    Organization.all( :include => [:organization_type, :country, :exchange, :listing_status, :sector, :communication_on_progresses],
                      :conditions => 'participant = true',
                      :select => 'organizations.*, C.*',
                      :joins => "LEFT JOIN (
                      SELECT
                        organization_id,
                        MAX(created_at) AS latest_cop,
                        COUNT(id) AS cop_count
                      FROM
                        communication_on_progresses
                      WHERE
                        state = 'approved'
                      GROUP BY
                         organization_id) as C ON organizations.id = C.organization_id"
                      )
  end

  def headers
    [ 'Participant ID',
      'Old ID',
      'Join Date',
      'Organization Type',
      'Country',
      'Company Name',
      'Sector',
      'Number of Employees',
      'FT500',
      'Region',
      'COP Status',
      'Active?',
      'Join Year',
      'COP Due Date',
      'Number of COPs',
      'Date of Last COP',
      'Inactive on',
      'Projected Delisting',
      'Listed Status',
      'Stock Code',
      'Exchange'
    ]
  end

  def row(record)
  [ record.id,
    record.old_id,
    record.joined_on,
    record.organization_type.name,
    record.country.name,
    record.name,
    record.sector_name,
    record.employees,
    record.is_ft_500,
    record.country.region,
    record.cop_state.titleize,
    record.active,
    record.joined_on.try(:year),
    record.cop_due_on,
    record.cop_count,
    record.latest_cop.try(:to_date),
    record.inactive_on,
    record.try(:delisting_on),
    record.listing_status.try(:name),
    record.stock_symbol,
    record.exchange.try(:name)
  ]
  end
end