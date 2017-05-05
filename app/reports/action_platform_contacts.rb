class ActionPlatformContacts < SimpleReport
  def records
    ActionPlatform::Subscription.includes(:organization, :contact, :platform)
  end

  def headers
    [
      'organization',
      'action_platform_name',
      'first_name',
      'last_name'
    ]
  end

  def row(record)
    [
      record.organization.name,
      record.platform.name,
      record.contact.first_name,
      record.contact.last_name
    ]
  end

end
