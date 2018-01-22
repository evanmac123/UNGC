class Organization::Policy

  def initialize(organization, contact)
    @organization = organization
    @contact = contact
  end

  def can_edit_video?
    @contact.from_ungc?
  end

  def can_view_video?
    @contact.from_ungc? ||
      @organization.contacts.include?(@contact)
  end

end
