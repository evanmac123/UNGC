class ParticipantApplications< SimpleReport

  def records
    Organization.applications_under_review.includes([country: :local_network], :sector, :organization_type, :listing_status)
  end

  def render_output
    self.render_xls
  end

  def headers
    [ 'Application ID',
      'Submitted on',
      'Relationship Manager',
      'Organization Name',
      'Country',
      'Status',
      'Organization Type',
      'Ownership',
      'Annual Revenue',
      'Sector',
      'Employees',
      'Pledge Made',
      'Local Network Name',
      'Last comment Date',
      'Review Reason'
    ]
  end

  def row(record)
    [ record.id,
      record.created_at,
      record.participant_manager_name,
      record.name,
      record.country_name,
      record.review_status_name,
      record.organization_type_name,
      record.listing_status_name,
      record.revenue_description,
      record.sector_name,
      record.employees,
      record.pledge_amount,
      record.local_network_name,
      record.last_comment_date,
      record.review_reason_value
    ]
  end
end
