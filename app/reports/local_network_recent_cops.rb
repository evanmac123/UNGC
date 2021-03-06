class LocalNetworkRecentCops < SimpleReport

  def records
    user = Contact.find(@options[:contact_id])
    CommunicationOnProgress.visible_to(user)
      .all_cops
      .approved
      .published_between(30.days.ago, Date.current)
      .order('communication_on_progresses.published_on DESC')
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
