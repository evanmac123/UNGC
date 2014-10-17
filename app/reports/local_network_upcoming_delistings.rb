class LocalNetworkUpcomingDelistings < SimpleReport

  def records
    contact = Contact.find(@options.fetch(:contact_id))
    Organization.active.visible_to(contact)
      .with_cop_status(:noncommunicating)
      .with_cop_due_between(Date.today - 1.year, Date.today - 1.year + 90.days)
      .all(:order => :cop_due_on)
  end

  def render_output
    self.render_xls
  end

  def headers
    [ 'Participant',
      'Participant Since',
      'Number of COPs',
      'Delisting Date'
    ]
  end

  def row(record)
    [ record.name,
      record.joined_on,
      record.communication_on_progresses.approved.try(:count),
      record.delisting_on
    ]
  end

end
