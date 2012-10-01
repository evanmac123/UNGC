class LocalNetworkRecentLogoRequests < SimpleReport

  def records
    LogoRequest.visible_to(@options[:user])
      .approved_between(30.days.ago.to_date, Date.today)
      .all(:order => 'approved_on DESC')
  end

  def headers
    [ 'Participant',
      'Publication Type',
      'Title / Purpose',
      'Approval Date'
    ]
  end

  def row(record)
    [ record.organization.name,
      record.publication.name,
      record.purpose,
      record.approved_on
    ]
  end

end