class AllLogoRequests < SimpleReport

  def records
    LogoRequest.find_by_sql("
    SELECT
        o.id AS 'participant_id',
        o.name AS 'participant_name',
        t.name AS 'organization_type',
        c.name AS 'country',
        c.region AS 'region',
        CASE o.revenue
            WHEN 1 THEN 'Less than USD 50 Million'
            WHEN 2 THEN 'Between USD 50 Million and USD 250 Million'
            WHEN 3 THEN 'Between USD 250 Million and USD 1 Billion'
            WHEN 4 THEN 'Between USD 1 Billion and USD 10 Billion'
            WHEN 5 THEN 'USD 10 Billion or more'
            ELSE '' END AS 'revenue',
        o.employees AS 'employees',
        p.name AS 'purpose',
        l.state AS 'review_status',
        DATE_FORMAT(l.created_at, '%Y-%m-%d') AS 'date_received',
        DATE_FORMAT(l.updated_at, '%Y-%m-%d') AS 'date_updated',
        l.approved_on AS 'date_approved',
        l.accepted_on AS 'date_policy_accepted'
    FROM logo_requests l
    JOIN organizations o
        ON o.id = l.organization_id
    JOIN organization_types t
        ON t.id = o.organization_type_id
    JOIN countries c
        ON o.country_id = c.id
    JOIN logo_publications p
        ON p.id = l.publication_id
    ORDER BY l.`created_at` DESC")
  end

  def headers
    [
    'Participant ID',
    'Participant Name',
    'Organization Type',
    'Country',
    'Region',
    'Revenue',
    'Employees',
    'Purpose',
    'Review Status',
    'Date Received',
    'Date Updated',
    'Date Approved',
    'Date Policy Accepted'
    ]
  end

  def row(record)
  [
    record.participant_id,
    record.participant_name,
    record.organization_type,
    record.country,
    record.region,
    record.revenue,
    record.employees,
    record.purpose,
    record.review_status,
    record.date_received,
    record.date_updated,
    record.date_approved,
    record.date_policy_accepted
  ]
  end

end
