class LocalNetworkUpcomingSmeDelistings < SimpleReport

  def records
    contact = Contact.find(@options.fetch(:contact_id))
    Organization.smes.visible_to(contact).under_moratorium.all(:order => :cop_due_on)
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
