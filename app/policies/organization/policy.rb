class Organization::Policy

  def initialize(organization, contact)
    raise "Contact cannot be nil" if contact.nil?
    raise "Organization cannot be nil" if organization.nil?

    @organization = organization
    @contact = contact
  end

  def can_edit_video?
    @contact.from_ungc?
  end

  def can_view_exclusionary_criteria?
    @contact.from_ungc? ||
      from_same_network? ||
      @organization.contacts.include?(@contact)
  end

  def can_edit_exclusionary_criteria?
    @contact.is?(Role.participant_manager) || @contact.from_integrity_managers?
  end

  private

  def from_same_network?
    @contact.belongs_to_network?(@organization.local_network)
  end

end
