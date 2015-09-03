class Contact::Creator

  def initialize(contact, policy)
    @contact = contact
    @policy = policy
  end

  def create
    unless policy.can_create?(contact)
      contact.errors.add(:base, 'You are not authorized to create that contact.')
      return false
    end
    
    unless policy.can_upload_image?(contact)
      contact.image = nil
    end

    contact.save
  end

  private

  attr_reader :contact, :policy

end
