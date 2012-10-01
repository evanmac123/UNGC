class LocalNetworkUpcomingDelistings < SimpleReport

  def records
    Organization.visible_to(@options[:user])
      .with_cop_status(:noncommunicating)
      .with_cop_due_between(Date.today - 1.year, Date.today - 1.year + 30.days)
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