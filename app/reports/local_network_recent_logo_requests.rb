class LocalNetworkRecentLogoRequests < SimpleReport

  def records
    contact = Contact.find(@options.fetch(:contact_id))
    LogoRequest.visible_to(contact)
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
