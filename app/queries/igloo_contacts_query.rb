class IglooContactsQuery
  attr_reader :cutoff

  def initialize(cutoff = DateTime.new(2016, 1, 1))
    @cutoff = cutoff
  end

  def staff
    ungc_name = DEFAULTS[:ungc_organization_name]
    Contact.
      includes(:organization).
      joins(:organization).
      where("organizations.name = ?", ungc_name).
      where("contacts.updated_at >= ? or organizations.updated_at >= ?", cutoff, cutoff)
  end

  def action_platform_signatories
    tables = %w(contacts organizations sectors countries action_platform_subscriptions)
    recent_updates = tables.map { |t| "#{t}.updated_at >= ?" }.join(" or ")
    bind_params = tables.count.times.map { cutoff }

    Contact.
      includes(:organization).
      joins(:organization).
      joins("inner join action_platform_subscriptions on action_platform_subscriptions.contact_id = contacts.id").
      joins("left join sectors on sectors.id = organizations.sector_id").
      joins("left join countries on countries.id = contacts.country_id").
      where(recent_updates, *bind_params).
      select("contacts.*, action_platform_subscriptions.status as subscription_status")
  end

end
