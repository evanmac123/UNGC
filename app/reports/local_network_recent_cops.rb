class LocalNetworkRecentCops < SimpleReport

  def records
    contact = Contact.find(@options.fetch(:contact_id))
    CommunicationOnProgress.visible_to(contact)
      .all_cops
      .approved
      .published_between(30.days.ago, Date.today)
      .all(:order => 'communication_on_progresses.published_on DESC')
  end

  def render_output
    self.render_xls
  end

  def headers
    [ 'Participant Name',
      'Published',
      'Title',
      'Differentiation'
    ]
  end

  def row(record)
    [ record.organization_name,
      record.published_on.to_date,
      record.title,
      record.differentiation_level_name
    ]
  end

end
