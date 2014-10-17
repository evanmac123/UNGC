class LocalNetworkParticipantsWithdrawn < SimpleReport

  def records
    contact = Contact.find(@options.fetch(:contact_id))
    Organization.visible_to(contact)
      .withdrew
      .delisted_between(Date.new(Date.today.year,1,1), Date.today)
      .all(:order => 'delisted_on DESC')
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
