class Contact::DefaultPolicy

  def initialize(contact)
    @contact = contact
  end

  def can_upload_image?(contact)
    false
  end

  def can_create?(contact)
    false
  end

  def can_update?(contact)
    false
  end

  def can_destroy?(contact)
    false
  end

  def can_sign_in?
    true
  end

end
