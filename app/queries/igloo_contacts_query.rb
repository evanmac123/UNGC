class IglooContactsQuery

  def run
    ungc_staff.to_a + action_platform_signatories.to_a
  end

  private

  def cutoff
    5.minutes.ago
  end

  def ungc_staff
    ungc_name = DEFAULTS[:ungc_organization_name]
    Contact.
      includes(:organization).
      joins(:organization).
      where("organizations.name = ?", ungc_name).
      where("contacts.updated_at >= ? or organizations.updated_at >= ?", cutoff, cutoff).
      select(:id, :first_name, :last_name, :job_title)
  end

  def action_platform_signatories
    Contact.
      includes(:organization).
      joins(:organization).
      joins("inner join action_platform_subscriptions on action_platform_subscriptions.contact_id = contacts.id").
      joins("left join sectors on sectors.id = organizations.sector_id").
      joins("left join countries on countries.id = contacts.country_id").
      where("contacts.updated_at >= ? or organizations.updated_at >= ? or sectors.updated_at >= ? or countries.updated_at >=?", cutoff, cutoff, cutoff, cutoff)
  end

end
