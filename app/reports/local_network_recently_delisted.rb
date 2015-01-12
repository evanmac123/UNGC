class LocalNetworkRecentlyDelisted < SimpleReport

  def records
    user = Contact.find(@options[:contact_id])
    Organization.visible_to(user)
      .with_cop_status(:delisted)
      .delisted_between(Date.today - 90.days, Date.today)
      .order('delisted_on DESC')
  end

  def render_output
    self.render_xls
  end

  def headers
    [ 'Participant',
      'Participant Since',
      'Delisting Date'
    ]
  end

  def row(record)
    [ record.name,
      record.joined_on,
      record.delisted_on
    ]
  end

end
