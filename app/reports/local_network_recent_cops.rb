class LocalNetworkRecentCops < SimpleReport

  def records
    CommunicationOnProgress.local_networks_all_cops(sql_for_organization_scope).created_between(30.days.ago, Date.today)
  end

  def render_output
    self.render_xls
  end

  def headers
    [ 'Participant Name',
      'Received',
      'Title',
      'Differentiation'
    ]
  end

  def row(record)
    [ record.organization_name,
      record.created_at,
      record.title,
      record.differentiation_level_name
    ]
  end

end