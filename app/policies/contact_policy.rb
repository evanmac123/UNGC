class ContactPolicy

  def initialize(contact)
    @current_contact = contact
    @policy = create_policy(contact)
  end

  def can_upload_image?(contact)
    @policy.can_upload_image?(contact)
  end

  def can_create?(contact)
    @policy.can_create?(contact)
  end

  def can_update?(contact)
    if @current_contact == contact
      true
    else
      @policy.can_update?(contact)
    end
  end

  def can_destroy?(contact)
    if @current_contact == contact
      false # can't destroy yourself
    else
      @policy.can_destroy?(contact)
    end
  end

  def can_sign_in?
    @policy.can_sign_in?
  end

  private

  def create_policy(contact)
    case
    when contact.from_ungc?
      Contact::UngcPolicy.new(contact)
    when contact.from_network?
      Contact::LocalNetworkPolicy.new(contact)
    when contact.from_organization?
      Contact::OrganizationPolicy.new(contact)
    else
      Contact::DefaultPolicy.new(contact)
    end
  end

end
