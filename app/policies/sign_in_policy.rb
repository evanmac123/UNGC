class SignInPolicy < SimpleDelegator

  def initialize(current)
    if current.from_ungc?
      super(ForStaff.new(current))
    else
      super(ForLocalNetworks.new(current))
    end
  end

  class ForStaff
    def initialize(current)
      @current = current
    end

    def can_sign_in_as?(target)
      target.can_login?
    end

    def sign_in_targets(from: nil)
      organizations = from ||= Organization.all
      Contact.contact_points
        .joins(:organization)
        .merge(Organization.approved)
        .merge(organizations.visible_to(@current))
    end

    def can_sign_in_as_others?
      true
    end
  end

  class ForLocalNetworks
    def initialize(current)
      @current = current
    end

    def can_sign_in_as?(target)
      can_sign_in_as_others? && from_same_local_network_as?(target)
    end

    def sign_in_targets(from: nil)
      contacts_in_same_network_as(from)
    end

    def can_sign_in_as_others?
      # must be a network focal point or report recipient to sign in as others
      @current.roles.filtered(:network_focal_point, :network_report_recipient).any?
    end

    private

    def from_same_local_network_as?(contact)
      organizations = Organization.where(id: contact.organization_id)
      contacts_in_same_network_as(organizations).include?(contact)
    end

    def contacts_in_same_network_as(from)
      return Contact.none unless can_sign_in_as_others?

      organizations = from || Organization.all
      Contact.contact_points
        .joins(:organization)
        .merge(Organization.approved)
        .merge(organizations.visible_to(@current))
    end
  end

end
