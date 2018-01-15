class LocalNetworkUpcomingDelistings < SimpleReport

  def records
    # organization is not eagerly loaded once we get this user
    # including this rather blunt kludge until the background reports branch is merged
    user = Contact.includes(:organization).find(@options[:contact_id])

    Organization.active.visible_to(user)
      .with_cop_status(:noncommunicating)
      .with_cop_due_between(Date.current - 1.year, Date.current - 1.year + 90.days)
      .order(:cop_due_on)
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
