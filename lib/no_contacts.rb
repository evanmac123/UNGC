# rails runner 'NoContacts.new'

class NoContacts

  ids = Contact.contact_points.collect(&:organization_id)
  o = Organization.participants
        .active
        .companies_and_smes
        .where("id not in (?)", ids)
        .order("cop_due_on")
  o.each do |org|
    puts "#{org.id} \t #{org.cop_due_on} \t #{org.name}"
  end

end
