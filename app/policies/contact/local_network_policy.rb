class Contact::LocalNetworkPolicy

  def initialize(contact)
    raise 'Must be from a Local Network' unless contact.from_network?
    @local_network_contact = contact
  end

  def can_upload_image?(contact)
    from_same_network_as?(contact)
  end

  def can_create?(contact)
    contact_point_from_same_network_as?(contact) && contact_person_from_same_network_as?(contact)
  end

  def can_update?(contact)
    contact_point_from_same_network_as?(contact) && contact_person_from_same_network_as?(contact)
  end

  def can_destroy?(contact)
    contact_point_from_same_network_as?(contact) && contact_person_from_same_network_as?(contact)
  end

  private

  def from_same_network_as?(contact)
    contact.belongs_to_network?(@local_network_contact.local_network)
  end

  def contact_point_from_same_network_as?(contact)
    @local_network_contact.is?(Role.contact_point) && from_same_network_as?(contact)
  end

  def contact_person_from_same_network_as?(contact)
    @local_network_contact.is?(Role.network_focal_point) && from_same_network_as?(contact)
  end

end
