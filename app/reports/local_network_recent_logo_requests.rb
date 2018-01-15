class LocalNetworkRecentLogoRequests < SimpleReport

  def records
    user = Contact.find(@options[:contact_id])
    LogoRequest.visible_to(user)
      .approved_between(30.days.ago.to_date, Date.current)
      .order('approved_on DESC')
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
