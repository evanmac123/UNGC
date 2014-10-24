class ContactsForMailMerge < SimpleDelegator

  def initialize(cop_states)
    @cop_states = cop_states
    super(relation)
  end

  private

  def relation
    @relation ||= Contact.select("contacts.id,
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
                contacts.plaintext_password,
                org_country.name AS organization_country,
                o.joined_on,
                t.name AS organization_type_name,
                o.cop_state,
                s.name as sector_name,
                o.employees,
                o.is_ft_500,
                l.name as network_name,
                o.name as org_name,
                country.region,
                r.name as role_name,
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
                     contacts_roles.role_id IN (?)", @cop_states, [Role.ceo, Role.contact_point])
  end

end
