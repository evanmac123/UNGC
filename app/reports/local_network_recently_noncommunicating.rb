class LocalNetworkRecentlyNoncommunicating < SimpleReport

  def records
    Organization.participants_with_cop_info(sql_for_organization_scope)
      .with_cop_status(:noncommunicating)
      .with_cop_due_between(Date.today - 30.days, Date.today)
  end

  def render_output
    self.render_xls
  end

  def headers
    [ 'Participant',
      'Participant Since',
      'COP past due date'
    ]
  end

  def row(record)
    [ record.name,
      record.joined_on,
      record.cop_due_on
    ]
  end

end