class DelistedParticipants < SimpleReport
  def records
    Organization.all( :include => [:country, :sector, :organization_type, :removal_reason],
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
                         organization_id) as C ON organizations.id = C.organization_id", 
                      :conditions => "organizations.cop_state NOT IN ('active','noncommunicating')"
                      )                      
  end
  
  def headers
    [ 'Participant ID',
      'Participant Name',
      'Number of Employees',
      'Join Date',
      'Join Year',
      'Delisted Date',
      'Organization Type',
      'FT500',
      'Sector',
      'Listed Status',
      'Stock Code',
      'Exchange', 
      'Country',
      'Region',
      'Latest COP',
      'Number of COPs',
      'Reason for Removal'      
    ]
  end

  def row(record)
  [ record.id,
    record.name,
    record.employees,
    record.joined_on,
    record.joined_on.try(:year),
    record.delisted_on,
    record.organization_type.name,
    record.is_ft_500,
    record.sector_name,
    record.listing_status.try(:name),
    record.stock_symbol,
    record.exchange.try(:name),
    record.country.name,
    record.country.region,
    record.latest_cop,
    record.cop_count,
    record.removal_reason.try(:description)
  ]
  end
end