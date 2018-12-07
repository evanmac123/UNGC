# frozen_string_literal: true

class Bulletin < SimpleReport

  def records
    query = <<-SQL
    SELECT
    CONCAT_WS(' ', c.first_name, c.last_name) AS fullname,
    c.email,
    o.name AS organization_name,
    o.id AS organization_id,
    CONCAT_WS(' ', c.prefix, c.last_name) AS prefix,
    (CASE WHEN (o.cop_state IN ('active', 'Active')) THEN 'active' ELSE 'non-communicating' END) AS cop_state,
    to_char(o.cop_due_on, 'YYYY-MM-DD') AS cop_due_on,
    (CASE WHEN (cop.latest_cop IS NULL) THEN 'No communication has been submitted' ELSE to_char(cop.latest_cop, 'YYYY-MM-DD') END) AS lastest_cop,
    (CASE WHEN (t.name IN ('Company','SME')) THEN 'COP' ELSE 'COE' END) AS cop_name,
    t.name IN ('Company','SME') AS is_business

    FROM contacts c
    JOIN organizations o ON c.organization_id = o.id
    JOIN countries country ON c.country_id = country.id
    JOIN organization_types t ON o.organization_type_id = t.id
    JOIN sectors s ON o.sector_id = s.id
    LEFT OUTER JOIN contacts_roles ON contacts_roles.contact_id = c.id
    RIGHT OUTER JOIN roles r ON r.id = contacts_roles.role_id
    LEFT JOIN (SELECT organization_id, MAX(published_on) AS latest_cop, COUNT(id) AS cop_count
    FROM communication_on_progresses
    WHERE state = 'approved'
    GROUP BY organization_id) AS cop ON o.id = cop.organization_id
    WHERE o.cop_state IN ('active','noncommunicating')
    AND o.active = TRUE
    AND o.participant = TRUE
    AND contacts_roles.role_id = 3

    UNION

    SELECT
    CONCAT_WS(' ', c.first_name, c.last_name) AS fullname,
    c.email,
    l.name AS organization_name,
    NULL AS organization_id,
    CONCAT_WS(' ', c.prefix, c.last_name) AS prefix,
    NULL AS cop_state,
    NULL AS cop_due_on,
    NULL AS latest_cop,
    NULL AS cop_name,
    FALSE AS is_business

    FROM contacts c
    JOIN local_networks l ON c.local_network_id = l.id
    JOIN countries country ON c.country_id = country.id
    LEFT OUTER JOIN contacts_roles ON contacts_roles.contact_id = c.id
    RIGHT OUTER JOIN roles r ON r.id = contacts_roles.role_id
    WHERE contacts_roles.role_id IN (4,7,10,11)
    AND c.local_network_id IS NOT NULL
    AND l.state != 'inactive'

    SQL

    ActiveRecord::Base.connection.execute(query)
  end

  def render_output
    self.render_xls
  end

  def headers
    [
      'Full Name',
      'Email',
      'Organization Name',
      'Organization ID',
      'Prefix',
      'CoP State',
      'CoP Due On',
      'Latest CoP',
      'CoP Name',
      'Is Business'
    ]
  end

  def row(record)
    [
      record["fullname"],
      record["email"],
      record["organization_name"],
      record["organization_id"],
      record["prefix"],
      record["cop_state"],
      record["cop_due_on"],
      record["latest_cop"],
      record["cop_name"],
      record["is_business"],
    ]
  end
end
