class ActionPlatformContacts < SimpleReport
  def records
    ActionPlatform::Subscription.includes(:organization, :contact, :platform)
  end

  def headers
    [
      'organization',
      'pariticpant id'
      'action platform name',
      'first name',
      'last name'
    ]
  end

  def row(record)
    [
      record.organization.name,
      record.organization_id,
      record.platform.name,
      record.contact.first_name,
      record.contact.last_name
    ]
  end

end
