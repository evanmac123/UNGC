class LocalNetworkUpcomingCops < SimpleReport

  def records
    Organization.participants_with_cop_info(sql_for_organization_scope).with_cop_due_between(Date.today, Date.today + 30.days)
  end

  def render_output
    self.render_xls
  end

  def headers
    [ 'Participant',
      'COP Status',
      'Participant Since',
      'COP Due Date'
    ]
  end

  def row(record)
    [ record.organization_name,
      record.organization_name,
      record.organization_name,
      record.organization_name
    ]
  end

end