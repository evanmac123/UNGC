class ActionPlatformContacts < SimpleReport
  def records
    ActionPlatform::Subscription.includes(:organization, :contact, :platform)
  end

  def headers
    [
      'Organization',
      'Pariticpant Id',
      'Action Platform Name',
      'First Name',
      'Last Name',
      'Email'
    ]
  end

  def row(record)
    [
      record.organization.name,
      record.organization_id,
      record.platform.name,
      record.contact.first_name,
      record.contact.last_name,
      record.contact.email
    ]
  end

end
