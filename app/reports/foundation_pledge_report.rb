class FoundationPledgeReport < SimpleReport
  def records
    Organization.active.participants.with_pledge.joined_on(@options[:month].to_i, @options[:year].to_i).all(:order => 'joined_on')
  end
  
  def headers
    [ 'Contact',
      'Email',
      'Phone',
      'Company',
      'Country',
      'Invoice ID',
      'Pledge',
      'Invoice Date']
  end

  def row(r)
    [ r.contacts.contact_points.first.name,
      r.contacts.contact_points.first.email,
      r.contacts.contact_points.first.phone,
      r.try(:name),
      r.country.try(:name),
      r.invoice_id,
      r.pledge_amount,
      r.joined_on]
  end
end