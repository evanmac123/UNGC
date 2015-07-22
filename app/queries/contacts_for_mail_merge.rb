class ContactsForMailMerge < SimpleDelegator

  def initialize(cop_states)
    super(relation(cop_states))
  end

  private

  def relation(cop_states)
    Contact.select("contacts.id,
                contacts.prefix,
                contacts.first_name,
                contacts.last_name,
                contacts.job_title,
                contacts.email,
                contacts.address,
                contacts.address_more,
                contacts.city,
                contacts.state,
                contacts.postal_code,
                contacts.phone,
                contacts.fax,
                contacts.username,
                contacts.organization_id,
                contacts.welcome_package,
                contacts.local_network_id,
                org_country.name AS organization_country,
                o.joined_on,
                o.cop_state,
                o.employees,
                o.is_ft_500,
                o.name as org_name,
                t.name AS organization_type_name,
                s.name as sector_name,
                l.name as network_name,
                r.name as role_name,
                country.region,
                country.name AS country_name_for_mail_merge")
      .joins("JOIN organizations o ON contacts.organization_id = o.id
               JOIN countries country ON contacts.country_id = country.id
               JOIN countries org_country ON o.country_id = org_country.id
               JOIN organization_types t ON o.organization_type_id = t.id
               JOIN sectors s ON o.sector_id = s.id
               LEFT JOIN local_networks l ON contacts.local_network_id = l.id
               LEFT OUTER JOIN contacts_roles ON contacts_roles.contact_id = contacts.id
               RIGHT OUTER JOIN roles r ON r.id = contacts_roles.role_id")
      .where("o.cop_state IN (?) AND
                     o.participant = 1 AND
                     t.name NOT IN ('Media Organization', 'GC Networks', 'Mailing List') AND
                     contacts_roles.role_id IN (?)", cop_states, [Role.ceo, Role.contact_point])
  end

end
