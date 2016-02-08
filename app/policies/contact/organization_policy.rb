class Contact::OrganizationPolicy

  def initialize(contact)
    raise 'Must be from an organization' unless contact.from_organization?
    @organization_contact = contact
  end

  def can_upload_image?(contact)
    false # organization contacts can't upload images.
  end

  def can_create?(contact)
    from_same_organization_as?(contact)
  end

  def can_update?(contact)
    from_same_organization_as?(contact)
  end

  def can_destroy?(contact)
    @organization_contact.organization.participant? && from_same_organization_as?(contact)
  end

  private

  def from_same_organization_as?(contact)
    contact.from_organization? \
    && contact.organization_id == @organization_contact.organization_id
  end

end
