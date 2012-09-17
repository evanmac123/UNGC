class LocalNetworkParticipantsWithdrawn < SimpleReport

  def records
    Organization.visible_to(@options[:user])
      .withdrew
      .delisted_between(Date.new(Date.today.year,1,1), Date.today)
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
