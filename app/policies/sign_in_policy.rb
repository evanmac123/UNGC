class SignInPolicy

  def initialize(current)
    @current = current
  end

  def can_sign_in_as?(target)
    report_recipient? && from_same_local_network_as?(target) && valid_target?(target)
  end

  def can_sign_in_as_contact_points?
    report_recipient?
  end

  def sign_in_targets(from: nil)
    contacts_in_same_network_as(from)
  end

  private

  def report_recipient?
    @current.is?(Role.network_report_recipient)
  end

  def valid_target?(contact)
    contact.is?(Role.contact_point)
  end

  def from_same_local_network_as?(contact)
    organizations = Organization.where(id: contact.organization_id)
    contacts_in_same_network_as(organizations).include?(contact)
  end

  def contacts_in_same_network_as(organizations = nil)
    return Contact.none unless can_sign_in_as_contact_points?

    organizations ||= Organization.all
    Contact.contact_points
        .joins(:organization)
        .merge(Organization.approved)
        .merge(organizations.visible_to(@current))
  end

end

