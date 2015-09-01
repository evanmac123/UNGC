class Contact::Creator < SimpleDelegator

  def initialize(contact, policy)
    super(contact)
    @policy = policy
  end

  def create
    unless policy.can_upload_image?(contact)
      contact.image = nil
    end

    if policy.can_create?(contact)
      contact.save
    else
      contact.errors.add(:base, 'You are not authorized to create that contact.')
      false
    end
  end

  private

  attr_reader :policy

  def contact
    __getobj__
  end

end
