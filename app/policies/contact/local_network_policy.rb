class Contact::LocalNetworkPolicy

  def initialize(contact)
    raise 'Must be from a Local Network' unless contact.from_network?
    @local_network_contact = contact
  end

  def can_upload_image?(contact)
    from_same_network_as?(contact)
  end

  def can_create?(contact)
    in_allowed_role? && from_same_network_as?(contact)
  end

  def can_update?(contact)
    in_allowed_role? && from_same_network_as?(contact)
  end

  def can_destroy?(contact)
    in_allowed_role? && from_same_network_as?(contact)
  end

  private

  def from_same_network_as?(contact)
    contact.belongs_to_network?(@local_network_contact.local_network)
  end

  def in_allowed_role?
    @local_network_contact.is?(Role.contact_point) || @local_network_contact.is?(Role.network_focal_point)
  end

end
