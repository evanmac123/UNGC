class Contact::UngcPolicy

  def initialize(contact)
    raise 'Must be from the UNGC' unless contact.from_ungc?
  end

  def can_upload_image?(contact)
    true
  end

  def can_create?(contact)
    true
  end

  def can_update?(contact)
    true
  end

  def can_destroy?(contact)
    true
  end

  def can_sign_in?
    true
  end

end
