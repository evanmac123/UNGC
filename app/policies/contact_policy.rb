class ContactPolicy

  def initialize(current_contact)
    @current_contact = current_contact
  end

  def can_upload_image?(target_contact)
    case
    when current_contact.from_ungc?
      true
    when current_contact.from_network?
      from_same_network(target_contact)
    else
      false # organization contacts can't upload images.
    end
  end

  def can_create?(target_contact)
    case
    when current_contact.from_ungc?
      true
    when current_contact.from_network?
      from_same_network(target_contact)
    when current_contact.from_organization?
      from_same_organization(target_contact)
    else
      false
    end
  end

  def can_update?(target_contact)
    can_create?(target_contact)
  end

  private

  attr_reader :contact

  def from_same_network(target_contact)
    target_contact.from_network? \
    && target_contact.local_network_id == current_contact.local_network_id
  end

  def from_same_organization(target_contact)
    target_contact.from_organization? \
    && target_contact.organization_id == current_contact.organization_id
  end

end
