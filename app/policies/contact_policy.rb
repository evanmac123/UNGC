class ContactPolicy

  def initialize(current_contact)
    @current_contact = current_contact
  end

  def can_upload_image?(target_contact)
    case
    when current_contact.from_ungc?
      true
    when current_contact.from_network?
      from_same_network_as?(target_contact)
    else
      false # organization contacts can't upload images.
    end
  end

  def can_create?(target_contact)
    case
    when current_contact.from_ungc?
      true
    when current_contact.from_organization?
      from_same_organization_as?(target_contact)
    when current_contact.from_network?
      contact_point_from_same_network_as?(target_contact)
    else
      false
    end
  end

  def can_update?(target_contact)
    case
    when current_contact.from_ungc?
      true
    when current_contact.from_network?
      contact_point_from_same_network_as?(target_contact)
    when current_contact.from_organization?
      from_same_organization_as?(target_contact)
    else
      false
    end
  end

  def can_destroy?(target_contact)
    case
    when current_contact == target_contact
      false # can't destroy yourself
    when current_contact.from_ungc?
      true
    when current_contact.from_network?
      contact_point_from_same_network_as?(target_contact)
    when current_contact.from_organization?
      current_contact.organization.participant? && from_same_organization_as?(target_contact)
    else
      false
    end
  end

  private

  attr_reader :current_contact

  def from_same_network_as?(target_contact)
    target_contact.belongs_to_network?(current_contact.local_network)
  end

  def contact_point_from_same_network_as?(contact)
    current_contact.is?(Role.contact_point) && from_same_network_as?(contact)
  end

  def from_same_organization_as?(target_contact)
    target_contact.from_organization? \
    && target_contact.organization_id == current_contact.organization_id
  end

end
