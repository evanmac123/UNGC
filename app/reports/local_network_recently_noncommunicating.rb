class LocalNetworkRecentlyNoncommunicating < SimpleReport

  def records
    user = Contact.find(@options.fetch(:user))
    Organization.visible_to(user)
      .with_cop_status(:noncommunicating)
      .with_cop_due_between(Date.today - 30.days, Date.today)
      .order(:cop_due_on)
  end

  def render_output
    self.render_xls
  end

  def headers
    [ 'Participant',
      'Participant Since',
      'Number of COPs',
      'COP past due date'
    ]
  end

  def row(record)
    [ record.name,
      record.joined_on,
      record.communication_on_progresses.approved.try(:count),
      record.cop_due_on
    ]
  end

end
