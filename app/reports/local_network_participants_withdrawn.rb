class LocalNetworkParticipantsWithdrawn < SimpleReport

  def records
    user = Contact.find(@options[:contact_id])
    Organization.visible_to(user)
      .withdrew
      .delisted_between(Date.new(Date.current.year,1,1), Date.current)
      .order('delisted_on DESC')
  end

  def headers
    [ 'Participant',
      'Participant Since',
      'Withdrawal Date',
    ]
  end

  def row(record)
  [ record.name,
    record.joined_on,
    record.delisted_on.try(:to_date),
  ]
  end

end
