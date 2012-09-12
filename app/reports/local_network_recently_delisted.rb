class LocalNetworkRecentlyDelisted < SimpleReport

  def records
    Organization.participants_with_cop_info(sql_for_organization_scope)
      .with_cop_status(:delisted)
      .delisted_between(Date.today - 90.days, Date.today)
  end

  def render_output
    self.render_xls
  end

  def headers
    [ 'Participant',
      'Participant Since',
      'Delisting Date'
    ]
  end

  def row(record)
    [ record.name,
      record.joined_on,
      record.delisted_on
    ]
  end

end