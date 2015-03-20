class LocalNetworkUpcomingCops < SimpleReport

  def records
    user = Contact.find(@options[:contact_id])
    Organization.visible_to(user)
      .with_cop_due_between(Date.today, Date.today + 30.days)
      .order(:cop_due_on)
  end

  def render_output
    self.render_xls
  end

  def headers
    [ 'Participant',
      'COP Status',
      'Participant Since',
      'COP Due Date'
    ]
  end

  def row(record)
    [ record.name,
      record.cop_state.humanize,
      record.joined_on,
      record.cop_due_on
    ]
  end

end
